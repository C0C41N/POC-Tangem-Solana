//
//  SignAsync.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 06/10/2024.
//

import Foundation
import TangemSdk

extension TangemSdk {
    func signAsync(hash: Data, walletPublicKey: Data) async -> Result<String, Error> {
        await withCheckedContinuation { continuation in
            self.sign(hash: hash, walletPublicKey: walletPublicKey) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: .success(response.signature.hexString))
                case .failure(let error):
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
}
