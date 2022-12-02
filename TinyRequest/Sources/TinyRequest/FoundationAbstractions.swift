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


/// Abstraction for URLSession
public protocol URLSessionProtocol {
    func dataPublisher(for request: URLRequestProtocol) -> AnyPublisher<Data, Error>
}

extension URLSession: URLSessionProtocol {
    public func dataPublisher(for request: URLRequestProtocol) -> AnyPublisher<Data, Error> {
        if let urlRequest = request as? URLRequest {
            return self.dataTaskPublisher(for: urlRequest)
                       .tryMap { data, response -> Data in
                           if let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode != 200 {
                              throw TinyErrors.invalidResponse(response)
                           }
                    return data
                }
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TinyErrors.invalidRequest).eraseToAnyPublisher()
        }
    }
}
