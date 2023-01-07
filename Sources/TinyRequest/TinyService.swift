//
//  File.swift
//  
//
//  Created by X_coder on 05/01/2023.
//

import Foundation
import Combine

public protocol TinyServiceProtocol {
    
    var url: URL? {get}
    var baseUrl: String {get}
    var urlPath: String {get}
    var queryItems: [URLQueryItem]? {get}
    
    var method: String {get}
    var header: [String: String]? {get}
    var body: Data? {get}
    
    var decoder: JSONDecoder {get}
    
    func dataResponsePublisher() -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
    func dataPublisher() -> AnyPublisher<Data, URLError>
    func responsePublisher() -> AnyPublisher<URLResponse, URLError>
    func objectPublisher<T: Decodable>(type: T.Type) -> AnyPublisher<T, Error>
}

extension TinyServiceProtocol {
    
    public var url: URL? {
        nil
    }
    
    public func dataResponsePublisher() -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        
        var validURL: URL
        
        // Preparing the URL
        if let url = self.url {
            validURL = url
            
        } else if let url = URL(string: self.baseUrl + self.urlPath) {
            validURL = url
            
        } else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        // Add query items to URL
        if let queryItems = self.queryItems,
           let queryUrl = validURL.append(queryItems: queryItems) {
            validURL = queryUrl
        }
        
        // Adding method, header and body for the request
        var tinyRequest = TinyRequest(url: validURL)
            .set(method: self.method)
        
        if let header = self.header {
            tinyRequest = tinyRequest.set(header: header)
        }
        
        if let body = self.body {
            tinyRequest = tinyRequest.set(body: body)
        }
        
        return tinyRequest.outputResponsePublisher()
    }
    
    public func objectPublisher<T>(type: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        dataResponsePublisher()
            .map(\.data)
            .decode(type: T.self, decoder: self.decoder)
            .eraseToAnyPublisher()
    }
    
    public func dataPublisher() -> AnyPublisher<Data, URLError> {
        dataResponsePublisher()
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    public func responsePublisher() -> AnyPublisher<URLResponse, URLError> {
        dataResponsePublisher()
            .map(\.response)
            .eraseToAnyPublisher()
    }
}
