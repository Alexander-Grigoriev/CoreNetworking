//
//  File.swift
//  
//
//  Created by Alexandr Grigoriev on 16.01.2026.
//

import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct Endpoint: Sendable {
    public let method: HTTPMethod
    public let path: String
    public let queryItems: [URLQueryItem]

    public init(
        method: HTTPMethod = .get,
        path: String,
        queryItems: [URLQueryItem] = []
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
    }

    public func makeRequest(baseURL: URL, headers: [String: String] = [:]) -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = path
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

