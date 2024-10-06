//
//  CreateWalletTask+.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 06/10/2024.
//

import TangemSdk

extension CreateWalletTask {
    public func runAsync(in session: CardSession) async -> Eval<CreateWalletResponse, Error> {
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
