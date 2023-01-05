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
    var method: String {get}
    
    var header: [String: String]? {get}
    var body: Data? {get}
    
    var decoder: JSONDecoder {get}
    
    func outputResponsePublisher() -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
    func dataPublisher() -> AnyPublisher<Data, URLError>
    func responsePublisher() -> AnyPublisher<URLResponse, URLError>
    func objectPublisher<T: Decodable>(type: T.Type) -> AnyPublisher<T, Error>
}

extension TinyServiceProtocol {
    public func outputResponsePublisher() -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError> {
        
        guard let url = self.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var tinyRequest = TinyRequest(url: url).set(method: self.method)
        
        if let header = self.header {
            tinyRequest = tinyRequest.set(header: header)
        }
        
        if let body = self.body {
            tinyRequest = tinyRequest.set(body: body)
        }
        
        return tinyRequest.outputResponsePublisher()
    }
    
    public func objectPublisher<T>(type: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        outputResponsePublisher()
            .map(\.data)
            .decode(type: T.self, decoder: self.decoder)
            .eraseToAnyPublisher()
    }
    
    public func dataPublisher() -> AnyPublisher<Data, URLError> {
        outputResponsePublisher()
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    public func responsePublisher() -> AnyPublisher<URLResponse, URLError> {
        outputResponsePublisher()
            .map(\.response)
            .eraseToAnyPublisher()
    }
}
