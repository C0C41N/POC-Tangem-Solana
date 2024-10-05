//
//  Actions.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import TangemSdk
import Solana

class Actions {

    private let tangemSdk = TangemProvider.getTangemSdk()

    func scan() {

        tangemSdk.scanCard(initialMessage: Message(header: "Scan Card", body: "Tap Tangem Card to learn more")) { result in

            guard let card = try? result.get() else {
                print("Failed to scan card.")
                return
            }

            print(card.json)

            card.wallets.enumerated().forEach { index, wallet in
                print("Wallet \(index) curve [\(wallet.curve.rawValue)] publicKeyBase58: [\(wallet.publicKey.base58EncodedString)]")
            }

        }

    }

    func sign(unsignedHex: String, pubKeyBase58: String) {

        let pubKeyData = Data(Base58.decode(pubKeyBase58))
        let hashData = Data(hexString: unsignedHex)

        tangemSdk.sign(hash: hashData, walletPublicKey: pubKeyData) { result in

            switch result {

                case .success(let response):
                    print("Signature: \(response.signature.hexString)")

                case .failure(let error):
                    print("signing failed!")

            }

        }

    }
    
}
