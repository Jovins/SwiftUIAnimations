//
//  ApiServiceError.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation

enum ApiServiceError: Error {
    
    case responseError
    case parseError(Error)
}
