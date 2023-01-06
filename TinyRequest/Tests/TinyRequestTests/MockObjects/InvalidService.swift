//
//  File.swift
//  
//
//  Created by X_coder on 06/01/2023.
//

import Foundation
@testable import TinyRequest

enum InvalidService {
    case downloadSomething
    case uploadSomething
}

extension InvalidService: TinyServiceProtocol {
    var url: URL? {
        nil
    }
    
    var baseUrl: String {
        "https://www.this-is-an-invalid-url.com"
    }
    
    var urlPath: String {
        "/download/something"
    }
    
    var queryItems: [URLQueryItem]? {
        return [URLQueryItem(name: "firstName", value: "James")]
    }
    
    var method: String {
        TinyRequestMethod.post.rawValue
    }
    
    var header: [String : String]? {
        ["header": "token"]
    }
    
    var body: Data? {
        ["body": "some text here" ].toData()
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
}
