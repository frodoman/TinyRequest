//
//  File.swift
//  
//
//  Created by X_coder on 01/12/2022.
//

import Foundation
@testable import TinyRequest

final class MockURLRequest: URLRequestProtocol {
    var httpMethod: String?
    
    var httpBody: Data?
    
    var allHTTPHeaderFields: [String : String]? = [:]
    
    func addValue(_ value: String,
                  forHTTPHeaderField field: String) {
        allHTTPHeaderFields?[field] = value
    }
    
}
