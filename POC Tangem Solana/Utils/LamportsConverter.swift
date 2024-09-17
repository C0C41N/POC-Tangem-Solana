//
//  LamportsConverter.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 17/09/2024.
//

import Foundation

class LamportsConverter {
    var lamports: UInt64
    var sol: Double

    private let lamportsPerSol: Double = 1_000_000_000

    init(lamports: UInt64) {
        self.lamports = lamports
        self.sol = Double(lamports) / lamportsPerSol
    }

    init(sol: Double) {
        self.sol = sol
        self.lamports = UInt64(sol * lamportsPerSol)
    }
}
