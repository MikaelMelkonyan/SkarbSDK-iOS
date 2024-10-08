//
//  SKStoreKitServiceImplementation.swift
//  ios
//
//  Created by Bitlica Inc. on 2/20/20.
//  Copyright © 2020 Ihnat Kandrashou. All rights reserved.
//

import Foundation
import StoreKit

class SKStoreKitServiceImplementation: NSObject, SKStoreKitService {
  
//  MARK: Public
  
  weak var delegate: SKStoreKitDelegate?
  
//  MARK: Private
  private let isObservable: Bool
  private let paymentQueue: SKPaymentQueue
  private var restorePurchasingCompletion: ((Result<Bool, Error>) -> Void)?
  private var purchasingProductCompletions: [String: ((Result<Bool, Error>) -> Void)]
  
  private let exclusionSerialQueue = DispatchQueue(label: "com.skarbSDK.skStoreKitService.exclusion")
  
  private var cachedAllProducts: [SKProduct]
  var allProducts: [SKProduct]? {
    var localAllProducts: [SKProduct]? = nil
    exclusionSerialQueue.sync {
      localAllProducts = cachedAllProducts
    }
    
    return localAllProducts
  }
  
  private typealias RequestProductCompletion = (Result<[SKProduct], Error>) -> Void
  private var requestProductsCompletions: [SKRequest: RequestProductCompletion]
  
  init(isObservable: Bool) {
    self.isObservable = isObservable
    self.paymentQueue = SKPaymentQueue.default()
    cachedAllProducts = []
    purchasingProductCompletions = [:]
    requestProductsCompletions = [:]
    super.init()
    self.paymentQueue.add(self)
  }
  
//  MARK: Public
  func requestProductInfoAndSendPurchase(command: SKCommand) {
    var editedCommand = command
    let decoder = JSONDecoder()
    
    guard let fetchProducts = try? decoder.decode(Array<SKFetchProduct>.self, from: command.data) else {
      SKLogger.logError("SKSyncServiceImplementation requestProductInfoAndSendPurchase: called with fetchProducts but command.data is not SKFetchProduct. Command.data == \(String(describing: String(data: command.data, encoding: .utf8)))", features: [SKLoggerFeatureType.internalError.name: SKLoggerFeatureType.internalError.name])
      editedCommand.changeStatus(to: .canceled)
      SKServiceRegistry.commandStore.saveCommand(editedCommand)
      return
    }
    
    requestProductsInfo(productIds: fetchProducts.map({ $0.productId })) { [weak self] result in
      switch result {
        case .success(let products):
          if !products.isEmpty {
            editedCommand.changeStatus(to: .done)
          } else {
            editedCommand.updateRetryCountAndFireDate()
            editedCommand.changeStatus(to: .pending)
          }
          SKServiceRegistry.commandStore.saveCommand(editedCommand)
          self?.createPriceCommand(fetchProducts: fetchProducts,
                                   products: products,
                                   command: editedCommand)
        case .failure(let error):
          SKLogger.logInfo("Getting error during fetching products. Error = \(error.localizedDescription)")
      }
    }
  }
  
  func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    SKLogger.logInfo("calling restorePurchases with SKPaymentQueue.restoreCompletedTransactions")
    restorePurchasingCompletion = completion
    paymentQueue.restoreCompletedTransactions()
  }
  
  func purchasePackage(_ package: SKOfferPackage, completion: @escaping (Result<Bool, Error>) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    let product = package.storeProduct
    SKLogger.logInfo("calling purchaseProduct with productId = \(product.productIdentifier)")
    let payment = SKMutablePayment(product: product)
    SKPaymentQueue.default().add(payment)
    exclusionSerialQueue.sync {
      purchasingProductCompletions[product.productIdentifier] = completion
    }
  }
  
  /// Might be called on any thread. Callback wil be on the main thread
  func requestProductsInfo(productIds: [String],
                           completion: @escaping (Result<[SKProduct], Error>) -> Void) {
    
    let request = SKProductsRequest(productIdentifiers: Set(productIds))
    request.delegate = self
    
    exclusionSerialQueue.sync {
      requestProductsCompletions[request] = completion
    }
    
    request.start()
  }
  
  func fetchProduct(by productId: String) -> SKProduct? {
    return allProducts?.filter({ $0.productIdentifier == productId }).first
  }
  
  var canMakePayments: Bool {
    return SKPaymentQueue.canMakePayments()
  }
}

//MARK: SKPaymentTransactionObserver
extension SKStoreKitServiceImplementation: SKPaymentTransactionObserver {
  
  
  /// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    var purchasedTransactions: [SKPaymentTransaction] = []
    
    transactions.forEach { transaction in
      delegate?.storeKitUpdatedTransaction(transaction)
      switch transaction.transactionState {
        case .purchased:
          purchasedTransactions.append(transaction)
        case .failed:
          failed(transaction)
        case .restored:
          restored(transaction)
        case .deferred, .purchasing: break
        @unknown default: break
      }
    }
    
    purchased(purchasedTransactions)
  }
  
  /// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
  public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    SKLogger.logInfo("paymentQueueRestoreCompletedTransactionsFinished was called")
    DispatchQueue.main.async {
      self.restorePurchasingCompletion?(.success(true))
      self.restorePurchasingCompletion = nil
    }
  }
  
  /// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
  public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    SKLogger.logInfo(String(format: "paymentQueueRestoreCompletedTransactionsFailedWithError was called with error %@", error.localizedDescription))
    DispatchQueue.main.async {
      self.restorePurchasingCompletion?(.failure(error))
      self.restorePurchasingCompletion = nil
    }
  }
  
  public func paymentQueue(_ queue: SKPaymentQueue,
                           shouldAddStorePayment payment: SKPayment,
                           for product: SKProduct) -> Bool {
    return delegate?.storeKit(shouldAddStorePayment: payment, for: product) ?? false
  }
}

extension SKStoreKitServiceImplementation: SKProductsRequestDelegate {
  
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    
    exclusionSerialQueue.sync {
      for product in response.products {
        if cachedAllProducts.filter({ $0.productIdentifier == product.productIdentifier }).first == nil {
          cachedAllProducts.append(product)
        }
      }
    }
    SKLogger.logInfo("SKRequestDelegate fetched products successful")
    
    var completion: RequestProductCompletion? = nil
    exclusionSerialQueue.sync {
      completion = self.requestProductsCompletions[request]
      self.requestProductsCompletions.removeValue(forKey: request)
    }
    
    DispatchQueue.main.async {
      completion?(.success(self.allProducts ?? []))
    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    
    SKLogger.logInfo("SKRequestDelegate got called with didFailWithError: \(error)")
    
    var completion: RequestProductCompletion? = nil
    exclusionSerialQueue.sync {
      completion = self.requestProductsCompletions[request]
      self.requestProductsCompletions.removeValue(forKey: request)
    }
    
    DispatchQueue.main.async {
      completion?(.failure(error))
    }
  }
}

//MARK: Private
private extension SKStoreKitServiceImplementation {
  
  private func purchased(_ transactions: [SKPaymentTransaction]) {

    guard !transactions.isEmpty else {
      return
    }
    
    // Sends success callback if purchasing was initiated by SkarbSDK.purchaseProduct(...) method
    for transaction in transactions {
      var purchaseCompletion: ((Result<Bool, Error>) -> Void)? = nil
      let productIdentifier = transaction.payment.productIdentifier
      exclusionSerialQueue.sync {
        purchaseCompletion = purchasingProductCompletions[productIdentifier]
        purchasingProductCompletions.removeValue(forKey: productIdentifier)
      }
      
      DispatchQueue.main.async {
        purchaseCompletion?(.success(true))
      }
    }
        
    for transaction in transactions {
      SKLogger.logInfo("paymentQueue updatedTransactions: called. TransactionState is purchased. ProductIdentifier = \(transaction.payment.productIdentifier), transactionDate = \(String(describing: transaction.transactionDate))")
    }
    
    createFetchProductsCommand(purchasedTransactions: transactions)
    createPurchaseAndTransactionCommand(purchasedTransactions: transactions)
    
    if !isObservable {
      transactions.forEach { paymentQueue.finishTransaction($0) }
    }
  }
  
  private func restored(_ transaction: SKPaymentTransaction) {
    if !isObservable {
      SKPaymentQueue.default().finishTransaction(transaction)
    }
  }
  
  private func failed(_ transaction: SKPaymentTransaction) {
    if !isObservable {
      SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    var purchaseCompletion: ((Result<Bool, Error>) -> Void)? = nil
    let productIdentifier = transaction.payment.productIdentifier
    exclusionSerialQueue.sync {
      purchaseCompletion = purchasingProductCompletions[productIdentifier]
      purchasingProductCompletions.removeValue(forKey: productIdentifier)
    }
    
    guard let error = transaction.error as? SKError else {
      if let error = transaction.error {
        DispatchQueue.main.async {
          purchaseCompletion?(.failure(error))
        }
      } else {
        DispatchQueue.main.async {
          purchaseCompletion?(.failure(SKResponseError(errorCode: 0, message: "Purchasing failed")))
        }
      }
      return
    }
    
    DispatchQueue.main.async {
      purchaseCompletion?(.failure(error))
    }
  }
  
  /// Create one SKFetchProduct or each unique productId.
  /// Need to attach the newest transaction Date and Id
  func createFetchProductsCommand(purchasedTransactions: [SKPaymentTransaction]) {
    let productIds = Array(Set(purchasedTransactions.map { $0.payment.productIdentifier }))
    var fetchProducts: [SKFetchProduct] = []
    for productId in productIds {
      let transaction = purchasedTransactions
        .filter { $0.payment.productIdentifier == productId }
        .sorted { $0.transactionDate ?? Date() < $1.transactionDate ?? Date() }.last
      if let transaction = transaction {
        fetchProducts.append(SKFetchProduct(productId: transaction.payment.productIdentifier,
                                            transactionDate: transaction.transactionDate,
                                            transactionId: transaction.transactionIdentifier))
      }
    }
    let encoder = JSONEncoder()
    if let productData = try? encoder.encode(fetchProducts) {
      let fetchCommand = SKCommand(commandType: .fetchProducts,
                                   status: .pending,
                                   data: productData)
      SKServiceRegistry.commandStore.saveCommand(fetchCommand)
    } else {
      SKLogger.logError("paymentQueue updatedTransactions: called. Need to fetch products but purchasedProductId.data(using: .utf8) == nil",
                        features: [SKLoggerFeatureType.internalError.name: SKLoggerFeatureType.internalError.name,
                                   SKLoggerFeatureType.internalValue.name: fetchProducts.description])
    }
  }
  
  func createPurchaseAndTransactionCommand(purchasedTransactions: [SKPaymentTransaction]) {
    let transactionIds: [String] = purchasedTransactions.compactMap { $0.transactionIdentifier }
    let countryCode: String? = SKPaymentQueue.default().storefront?.countryCode
    let installData = SKServiceRegistry.commandStore.getDeviceRequest()
    if !SKServiceRegistry.commandStore.hasPurhcaseV4Command {
      let purchaseDataV4 = Purchaseapi_ReceiptRequest(storefront: countryCode,
                                                      region: allProducts?.first?.priceLocale.region?.identifier,
                                                      currency: allProducts?.first?.priceLocale.currency?.identifier,
                                                      newTransactions: transactionIds,
                                                      docFolderDate: installData?.docDate,
                                                      appBuildDate: installData?.buildDate)
      let purchaseV4Command = SKCommand(commandType: .purchaseV4,
                                        status: .pending,
                                        data: purchaseDataV4.getData())
      SKServiceRegistry.commandStore.saveCommand(purchaseV4Command)
    }
    
    // Just no need to send receipt for duplicated product identifiers
    let productIdentifiers = Set(purchasedTransactions.compactMap { $0.payment.productIdentifier })
    for productId in productIdentifiers {
      // default is true bacause we may not have [SKProduct] and purchase might be not subscription
      // server should have each updated receipt at this case not to lose one time puchases
      // no needs to send receipt for subscription purchases
      var shouldSendPurchase = true
      if let product = fetchProduct(by: productId),
         product.introductoryPrice != nil {
        shouldSendPurchase = false
      }
      if shouldSendPurchase {
        let purchaseDataV4 = Purchaseapi_ReceiptRequest(storefront: countryCode,
                                                        region: allProducts?.first?.priceLocale.region?.identifier,
                                                        currency: allProducts?.first?.priceLocale.currency?.identifier,
                                                        newTransactions: transactionIds,
                                                        docFolderDate: installData?.docDate,
                                                        appBuildDate: installData?.buildDate)
        let purchaseV4Command = SKCommand(commandType: .setReceipt,
                                          status: .pending,
                                          data: purchaseDataV4.getData())
        SKServiceRegistry.commandStore.saveCommand(purchaseV4Command)
      }
    }
        
    // Always sends transactions even in case if it was the first purchase
    // and transactions are included into purchase command
    let newTransactions = SKServiceRegistry.commandStore.getNewTransactionIds(transactionIds)
    if !newTransactions.isEmpty {
      let installData = SKServiceRegistry.commandStore.getDeviceRequest()
      let transactionDataV4 = Purchaseapi_TransactionsRequest(newTransactions: newTransactions,
                                                              docFolderDate: installData?.docDate,
                                                              appBuildDate: installData?.buildDate)
      let transactionV4Command = SKCommand(commandType: .transactionV4,
                                           status: .pending,
                                           data: transactionDataV4.getData())
      SKServiceRegistry.commandStore.saveCommand(transactionV4Command)
    }
  }
  
  func createPriceCommand(fetchProducts: [SKFetchProduct],
                          products: [SKProduct],
                          command: SKCommand) {
    var priceApiProducts: [Priceapi_Product] = []
    for fetchProduct in fetchProducts {
      guard let product = products.first(where: { $0.productIdentifier == fetchProduct.productId }) else {
        SKLogger.logError("SKSyncServiceImplementation. Send command for price. Product is nil. FetchProduct = \(fetchProduct.productId)",
                          features: [SKLoggerFeatureType.internalError.name: SKLoggerFeatureType.internalError.name,
                                     SKLoggerFeatureType.retryCount.name: command.retryCount])
        continue
      }
      let priceApiProduct = Priceapi_Product(product: product,
                                             transactionDate: fetchProduct.transactionDate,
                                             transactionId: fetchProduct.transactionId)
      priceApiProducts.append(priceApiProduct)
    }
    
    guard !priceApiProducts.isEmpty else {
      return
    }
    
    let countryCode: String? = SKPaymentQueue.default().storefront?.countryCode
    let productRequest = Priceapi_PricesRequest(storefront: countryCode,
                                                region: products.first?.priceLocale.region?.identifier,
                                                currency: products.first?.priceLocale.currency?.identifier,
                                                products: priceApiProducts)
    let command = SKCommand(commandType: .priceV4,
                            status: .pending,
                            data: productRequest.getData())
    SKServiceRegistry.commandStore.saveCommand(command)
  }
}
