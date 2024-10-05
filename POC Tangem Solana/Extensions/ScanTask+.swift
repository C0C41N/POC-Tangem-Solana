//
//  ScanTask+.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 06/10/2024.
//

import TangemSdk

extension ScanTask {
    public func runAsync(in session: CardSession) async -> Result<Card, TangemSdkError> {
        await withCheckedContinuation { continuation in
            self.run(in: session) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
