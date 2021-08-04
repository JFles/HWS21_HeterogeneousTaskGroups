//
//  URLSession+Ext.swift
//  URLSession+Ext
//
//  Created by Jeremy Fleshman on 8/3/21.
//

import Foundation

/// Paul starts with this extension constantly
extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type = T.self, // T.self helps it figure out the type sometimes
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDeodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let (data, _) = try await data(from: url)
        /// Can check for cancellation after the network call returns
        try Task.checkCancellation()

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDeodingStrategy

        let decoded = try decoder.decode(T.self, from: data)
        return decoded
    }
}
