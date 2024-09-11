//
//  Actions.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import TangemSdk

class Actions {
    @Published var accessCodeRequestPolicy: AccessCodeRequestPolicy = .default
    private lazy var _tangemSdk: TangemSdk = { .init() }()
    private var tangemSdk: TangemSdk {
        var config = Config()
        config.linkedTerminal = false
        config.allowUntrustedCards = true
        config.handleErrors = true
        config.filter.allowedCardTypes = FirmwareVersion.FirmwareType.allCases
        config.accessCodeRequestPolicy = accessCodeRequestPolicy
        config.logConfig = .verbose
        config.defaultDerivationPaths = [
            .secp256k1: [try! DerivationPath(rawPath: "m/0'/1")],
            .secp256r1: [try! DerivationPath(rawPath: "m/0'/1")],
            .ed25519: [try! DerivationPath(rawPath: "m/0'/1")],
            .ed25519_slip0010: [try! DerivationPath(rawPath: "m/0'/1'")],
            .bip0340: [try! DerivationPath(rawPath: "m/0'/1")]
        ]
        _tangemSdk.config = config
        return _tangemSdk
    }
    
    func scan() {
        print("Calling tangemSdk.scan")
        tangemSdk.scanCard(initialMessage: Message(header: "Scan Card", body: "Tap Tangem Card to learn more")) { result in
            if case let .success(card) = result {
                let ed25519Wallets = card.wallets.filter { $0.curve == .ed25519 }
                
                if (ed25519Wallets.isEmpty) {
                    print("No Solana wallet found!")
                    return
                }
                
                print("publicKey of Solana Wallet:")
                ed25519Wallets.enumerated().forEach { index, wallet in
                    print("Wallet \(index): HexString[\(wallet.publicKey.hexString)]")
                }

            }
        }
    }
}
