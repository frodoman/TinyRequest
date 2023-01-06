//
//  File.swift
//  
//
//  Created by X_coder on 06/01/2023.
//

import Foundation

public extension URL {
    
    func append(queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(string: self.absoluteString) else {
            return nil
        }
        
        components.queryItems = queryItems
        return components.url
    }
}
