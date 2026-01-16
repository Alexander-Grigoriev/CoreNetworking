//
//  File.swift
//  
//
//  Created by Alexandr Grigoriev on 16.01.2026.
//

import Foundation

// MARK: - Transport

public protocol Transport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

public struct URLSessionTransport: Transport {
    public init() {}

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }
}

// MARK: - API Client

public protocol APIClient: Sendable {
    func request<T: Decodable>(_ request: URLRequest, as: T.Type) async throws -> T
}

public enum NetworkingError: Error, Sendable, Equatable {
    case nonHTTPResponse
    case httpStatus(Int)
}

public struct DefaultAPIClient: APIClient {
    private let transport: Transport
    private let decoder: JSONDecoder

    public init(transport: Transport, decoder: JSONDecoder = JSONDecoder()) {
        self.transport = transport
        self.decoder = decoder
    }

    public func request<T: Decodable>(_ request: URLRequest, as: T.Type) async throws -> T {
        let (data, http) = try await transport.send(request)
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkingError.httpStatus(http.statusCode)
        }
        return try decoder.decode(T.self, from: data)
    }
}
