// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: app_purchase_api.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct Apipurchase_Auth {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var key: String = String()

  var bundleID: String = String()

  var agentName: String = String()

  var agentVer: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Apipurchase_TransactionsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var auth: Apipurchase_Auth {
    get {return _auth ?? Apipurchase_Auth()}
    set {_auth = newValue}
  }
  /// Returns true if `auth` has been explicitly set.
  var hasAuth: Bool {return self._auth != nil}
  /// Clears the value of `auth`. Subsequent reads from it will return its default value.
  mutating func clearAuth() {self._auth = nil}

  /// random unique value, e.g. timestamp+rand(int64)
  var installID: String = String()

  var transactions: [String] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _auth: Apipurchase_Auth? = nil
}

struct Apipurchase_ReceiptRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var auth: Apipurchase_Auth {
    get {return _auth ?? Apipurchase_Auth()}
    set {_auth = newValue}
  }
  /// Returns true if `auth` has been explicitly set.
  var hasAuth: Bool {return self._auth != nil}
  /// Clears the value of `auth`. Subsequent reads from it will return its default value.
  mutating func clearAuth() {self._auth = nil}

  /// random unique value, e.g. timestamp+rand(int64)
  var installID: String = String()

  var transactions: [String] = []

  var idfa: String = String()

  var idfv: String = String()

  /// tbd: it's needed for sandbox check
  var receiptURL: String = String()

  var receiptLen: String = String()

  var receipt: Data = SwiftProtobuf.Internal.emptyData

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _auth: Apipurchase_Auth? = nil
}

struct Apipurchase_ReceiptResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var id: UInt64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "apipurchase"

extension Apipurchase_Auth: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Auth"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "key"),
    2: .standard(proto: "bundle_id"),
    3: .standard(proto: "agent_name"),
    4: .standard(proto: "agent_ver"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.key)
      case 2: try decoder.decodeSingularStringField(value: &self.bundleID)
      case 3: try decoder.decodeSingularStringField(value: &self.agentName)
      case 4: try decoder.decodeSingularStringField(value: &self.agentVer)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.key.isEmpty {
      try visitor.visitSingularStringField(value: self.key, fieldNumber: 1)
    }
    if !self.bundleID.isEmpty {
      try visitor.visitSingularStringField(value: self.bundleID, fieldNumber: 2)
    }
    if !self.agentName.isEmpty {
      try visitor.visitSingularStringField(value: self.agentName, fieldNumber: 3)
    }
    if !self.agentVer.isEmpty {
      try visitor.visitSingularStringField(value: self.agentVer, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Apipurchase_Auth, rhs: Apipurchase_Auth) -> Bool {
    if lhs.key != rhs.key {return false}
    if lhs.bundleID != rhs.bundleID {return false}
    if lhs.agentName != rhs.agentName {return false}
    if lhs.agentVer != rhs.agentVer {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Apipurchase_TransactionsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".TransactionsRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "auth"),
    2: .standard(proto: "install_id"),
    3: .same(proto: "transactions"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &self._auth)
      case 2: try decoder.decodeSingularStringField(value: &self.installID)
      case 3: try decoder.decodeRepeatedStringField(value: &self.transactions)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._auth {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if !self.installID.isEmpty {
      try visitor.visitSingularStringField(value: self.installID, fieldNumber: 2)
    }
    if !self.transactions.isEmpty {
      try visitor.visitRepeatedStringField(value: self.transactions, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Apipurchase_TransactionsRequest, rhs: Apipurchase_TransactionsRequest) -> Bool {
    if lhs._auth != rhs._auth {return false}
    if lhs.installID != rhs.installID {return false}
    if lhs.transactions != rhs.transactions {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Apipurchase_ReceiptRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ReceiptRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "auth"),
    2: .standard(proto: "install_id"),
    3: .same(proto: "transactions"),
    5: .same(proto: "idfa"),
    6: .same(proto: "idfv"),
    7: .standard(proto: "receipt_url"),
    8: .standard(proto: "receipt_len"),
    9: .same(proto: "receipt"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularMessageField(value: &self._auth)
      case 2: try decoder.decodeSingularStringField(value: &self.installID)
      case 3: try decoder.decodeRepeatedStringField(value: &self.transactions)
      case 5: try decoder.decodeSingularStringField(value: &self.idfa)
      case 6: try decoder.decodeSingularStringField(value: &self.idfv)
      case 7: try decoder.decodeSingularStringField(value: &self.receiptURL)
      case 8: try decoder.decodeSingularStringField(value: &self.receiptLen)
      case 9: try decoder.decodeSingularBytesField(value: &self.receipt)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if let v = self._auth {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }
    if !self.installID.isEmpty {
      try visitor.visitSingularStringField(value: self.installID, fieldNumber: 2)
    }
    if !self.transactions.isEmpty {
      try visitor.visitRepeatedStringField(value: self.transactions, fieldNumber: 3)
    }
    if !self.idfa.isEmpty {
      try visitor.visitSingularStringField(value: self.idfa, fieldNumber: 5)
    }
    if !self.idfv.isEmpty {
      try visitor.visitSingularStringField(value: self.idfv, fieldNumber: 6)
    }
    if !self.receiptURL.isEmpty {
      try visitor.visitSingularStringField(value: self.receiptURL, fieldNumber: 7)
    }
    if !self.receiptLen.isEmpty {
      try visitor.visitSingularStringField(value: self.receiptLen, fieldNumber: 8)
    }
    if !self.receipt.isEmpty {
      try visitor.visitSingularBytesField(value: self.receipt, fieldNumber: 9)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Apipurchase_ReceiptRequest, rhs: Apipurchase_ReceiptRequest) -> Bool {
    if lhs._auth != rhs._auth {return false}
    if lhs.installID != rhs.installID {return false}
    if lhs.transactions != rhs.transactions {return false}
    if lhs.idfa != rhs.idfa {return false}
    if lhs.idfv != rhs.idfv {return false}
    if lhs.receiptURL != rhs.receiptURL {return false}
    if lhs.receiptLen != rhs.receiptLen {return false}
    if lhs.receipt != rhs.receipt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Apipurchase_ReceiptResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ReceiptResponse"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularUInt64Field(value: &self.id)
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularUInt64Field(value: self.id, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Apipurchase_ReceiptResponse, rhs: Apipurchase_ReceiptResponse) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
