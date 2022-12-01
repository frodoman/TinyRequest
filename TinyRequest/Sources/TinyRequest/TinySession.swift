//
//  File.swift
//  
//
//  Created by X_coder on 01/12/2022.
//

import Foundation

public protocol TinySessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: TinySessionProtocol { }
