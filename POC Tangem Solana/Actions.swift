//
//  Actions.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import TangemSdk

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

        let pubKeyData = pubKeyBase58.base58DecodedData
        let hashData = Data(hexString: unsignedHex)

        Task {

            let result = await tangemSdk.signAsync(hash: hashData, walletPublicKey: pubKeyData)
            
            switch result {
            case .success(let signature):
                print("Signature: \(signature)")
            case .failure(let error):
                print("Signing failed: \(error)")
            }

        }

    }

    func createWallets() {
        print("Hello world!")
    }
    
}
