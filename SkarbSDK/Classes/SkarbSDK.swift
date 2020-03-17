//
//  SkarbSDK.swift
//  SkarbSDKExample
//
//  Created by Bitlica Inc. on 1/27/20.
//  Copyright © 2020 Bitlica Inc. All rights reserved.
//

import Foundation
import UIKit

public class SkarbSDK {
  public static func initialize(clientId: String,
                                isObservable: Bool,
                                deviceId: String? = nil,
                                isDebug: Bool) {
    SKServiceRegistry.initialize(isObservable: isObservable)
    SKServiceRegistry.userDefaultsService.setValue(clientId, forKey: .clientId)
    SKServiceRegistry.userDefaultsService.setValue(deviceId ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString, forKey: .deviceId)
    SKServiceRegistry.userDefaultsService.setValue(isDebug, forKey: .env)
    SKServiceRegistry.serverAPI.sendInstall(completion: { _ in })
  }
  
  public static func sendTest(name: String,
                              group: String,
                              completion: @escaping (SKResponseError?) -> Void) {
    SKServiceRegistry.serverAPI.sendTest(name: name, group: group, completion: completion)
  }
  
  public static func sendSource(broker: SKBroker,
                                features: [String: Any],
                                completion: @escaping (SKResponseError?) -> Void) {
    SKServiceRegistry.serverAPI.sendSource(broker: broker, features: features, completion: completion)
  }
  
  public static func sendPurchase(productId: String,
                                  price: Float? = nil,
                                  currency: String? = nil,
                                  completion: ((SKResponseError?) -> Void)? = nil) {
    SKServiceRegistry.serverAPI.sendPurchase(productId: productId,
                                             price: price,
                                             currency: currency,
                                             completion: completion)
  }
  
  public static func getDeviceId() -> String {
    return SKServiceRegistry.userDefaultsService.string(forKey: .deviceId) ?? UUID().uuidString
  }
}
