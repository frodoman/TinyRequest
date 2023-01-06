//
//  FoundationAbstractions.swift
//  
//
//  Created by X_coder on 01/12/2022.
//
//  Abstractions to fundation components
//

import Foundation
import Combine

/// Abstraction for URLRequest
public protocol URLRequestProtocol {
    var httpMethod: String? {get set}
    var httpBody: Data? {get set}
    var allHTTPHeaderFields: [String : String]? {get set}
    
    mutating func addValue(_ value: String, forHTTPHeaderField field: String)
}

extension URLRequest: URLRequestProtocol { }
