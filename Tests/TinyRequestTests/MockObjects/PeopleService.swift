//
//  File.swift
//  
//
//  Created by X_coder on 06/01/2023.
//

import Foundation
@testable import TinyRequest

enum PeopleService {
    // get a list of all people
    case getPeople
    
    // get one person
    case getPerson
}


extension PeopleService: TinyServiceProtocol {
    var url: URL? {
        switch self {
        case .getPeople:
            return try? MockData.urlForFile(name: "people", type: "json")
        case .getPerson:
            return try? MockData.urlForFile(name: "person", type: "json")
        }
    }
    
    var baseUrl: String {
        ""
    }
    
    var urlPath: String {
        ""
    }
    
    var queryItems: [URLQueryItem]? {
        nil
    }
    
    var method: String {
        TinyRequestMethod.get.rawValue
    }
    
    var header: [String : String]? {
        [:]
    }
    
    var body: Data? {
        Data()
    }
    
    var decoder: JSONDecoder {
        JSONDecoder()
    }
}

