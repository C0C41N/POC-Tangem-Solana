//
//  TangemProvider.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 12/09/2024.
//

import Foundation
import TangemSdk

class TangemProvider {

    private static var tangemSdk: TangemSdk = {

        var config = Config()

        config.linkedTerminal = false
        config.allowUntrustedCards = true
        config.handleErrors = true
        config.filter.allowedCardTypes = FirmwareVersion.FirmwareType.allCases
        config.accessCodeRequestPolicy = .alwaysWithBiometrics
        config.logConfig = .release

        config.defaultDerivationPaths = [
            .secp256k1: [try! DerivationPath(rawPath: "m/0'/1")],
            .secp256r1: [try! DerivationPath(rawPath: "m/0'/1")],
            .ed25519: [try! DerivationPath(rawPath: "m/0'/1")],
            .ed25519_slip0010: [try! DerivationPath(rawPath: "m/0'/1'")],
            .bip0340: [try! DerivationPath(rawPath: "m/0'/1")]
        ]

        let sdk = TangemSdk()
        sdk.config = config
        return sdk

    }()

    public static func getTangemSdk() -> TangemSdk {
        return tangemSdk
    }

}
