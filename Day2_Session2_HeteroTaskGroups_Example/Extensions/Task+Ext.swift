//
//  Task+Ext.swift
//  Task+Ext
//
//  Created by Jeremy Fleshman on 8/3/21.
//

import Foundation

/// extension to get `sleep` in `seconds` instead of `nanoseconds`
extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await sleep(nanoseconds: duration)
    }
}
