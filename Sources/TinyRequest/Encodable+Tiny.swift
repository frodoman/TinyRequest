//
//  File.swift
//  
//
//  Created by X_coder on 01/12/2022.
//

import Foundation

public extension Encodable {
    func toDictionary() -> [AnyHashable: Any]? {
        guard let data = toData() else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [AnyHashable: Any] }
    }
    
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
