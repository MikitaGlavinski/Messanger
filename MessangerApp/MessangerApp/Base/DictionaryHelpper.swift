//
//  DictionaryHelpper.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 19.01.22.
//

import Foundation

class DictionaryEncoder {
    
    private let encoder = JSONEncoder()
    
    func encode<T>(value: T) throws -> [String: Any] where T: Encodable {
        let data = try encoder.encode(value)
        return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any]
    }
}

class DictionaryDecoder {
    
    private let decoder = JSONDecoder()
    
    func decode<T>(dictionary: [String: Any], decodeType: T.Type) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
        return try decoder.decode(decodeType, from: data)
    }
}
