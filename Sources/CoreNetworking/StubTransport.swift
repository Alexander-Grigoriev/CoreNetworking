//
//  File.swift
//  
//
//  Created by Alexandr Grigoriev on 16.01.2026.
//

import Foundation

public struct StubTransport: Transport {
    public enum StubError: Error, Sendable, Equatable {
        case missingURL
        case missingResponse(path: String)
    }

    private let responses: [String: Data] // key: URL path (e.g. "/transactions")

    public init(responses: [String: Data]) {
        self.responses = responses
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard let url = request.url else { throw StubError.missingURL }
        let path = url.path

        guard let data = responses[path] else {
            throw StubError.missingResponse(path: path)
        }

        let http = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!

        return (data, http)
    }
}
