//
//  PurgeWalletCommand+.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 06/10/2024.
//

import TangemSdk

extension PurgeWalletCommand {
    public func runAsync(in session: CardSession) async -> Eval<SuccessResponse, Error> {
        await withCheckedContinuation { continuation in
            self.run(in: session) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: .success(response))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
}
