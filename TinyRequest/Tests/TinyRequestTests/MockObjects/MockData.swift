//
//  File.swift
//  
//
//  Created by X_coder on 06/01/2023.
//

import Foundation

struct MockData {
    static func urlForFile(name: String, type: String?) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: type) else {
            throw TestError.fileNotFound(name + (type ?? ""))
        }
        return url
    }
}
