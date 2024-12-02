//
//  ApiService.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/27.
//

import Foundation
import Combine

protocol ApiRequestType {
    
    associatedtype Response: Decodable
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
}

protocol ApiServiceType {
    
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, ApiServiceError> where Request: ApiRequestType
}

final class ApiService: ApiServiceType {
    
    private let baseURL: URL
    init(baseURL: URL = URL(string: "https://api.github.com")!) {
        
        self.baseURL = baseURL
    }
    
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, ApiServiceError> where Request : ApiRequestType {
        
        let pathURL = URL(string: request.path , relativeTo: baseURL)!
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, urlResponse in data }
            .mapError { _ in ApiServiceError.responseError }
            .decode(type: Request.Response.self, decoder: decoder)
            .mapError(ApiServiceError.parseError)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

