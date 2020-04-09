//
//  CommandType.swift
//  SkarbSDKExample
//
//  Created by Artem Hitrik on 4/3/20.
//  Copyright © 2020 Prodinfire. All rights reserved.
//

import Foundation

enum SKCommandAppgateType {
  case install
  case sourse
  case test
  case purchase
}

extension SKCommandAppgateType: Codable {
  
  enum Key: CodingKey {
    case rawValue
  }
  
  enum CodingError: Error {
    case unknownValue
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Key.self)
    let rawValue = try container.decode(Int.self, forKey: .rawValue)
    switch rawValue {
      case 0:
        self = .install
      case 1:
        self = .sourse
      case 2:
        self = .test
      case 3:
        self = .purchase
      default:
        throw CodingError.unknownValue
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    switch self {
      case .install:
        try container.encode(0, forKey: .rawValue)
      case .sourse:
        try container.encode(1, forKey: .rawValue)
      case .test:
      try container.encode(2, forKey: .rawValue)
      case .purchase:
      try container.encode(3, forKey: .rawValue)
    }
  }
}
