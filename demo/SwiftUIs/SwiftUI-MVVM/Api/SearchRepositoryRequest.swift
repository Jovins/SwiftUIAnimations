//
//  SearchRepositoryRequest.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation

struct SearchRepositoryRequest: ApiRequestType {
    
    typealias Response = SearchRepositoryResponse
    var path: String { return "/search/repositories" }
    var queryItems: [URLQueryItem]? {
        return [
            .init(name: "q", value: "SwiftUI"),
            .init(name: "order", value: "desc")
        ]
    }
}
