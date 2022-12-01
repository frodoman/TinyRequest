//
//  File.swift
//  
//
//  Created by X_coder on 01/12/2022.
//

import Foundation

public enum TinyErrors: Error {
    case invalidURL
    case invalidResponse(URLResponse)
}
