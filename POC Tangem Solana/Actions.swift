//
//  Actions.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import TangemSdk

class Actions {

    private var blockchain = Blockchain()
    private let tangemSdk = TangemProvider.getTangemSdk()
    
    func scan() {

        tangemSdk.scanCard(initialMessage: Message(header: "Scan Card", body: "Tap Tangem Card to learn more")) { result in

            guard let card = try? result.get() else {
                print("Failed to scan card.")
                return
            }

            card.wallets.enumerated().forEach { index, wallet in
                print("Wallet \(index) curve [\(wallet.curve.rawValue)] publicKey: [\(wallet.publicKey.base58EncodedString)]")
            }

        }

    }



    func trx() {

        print("initiating trx()")
        blockchain.trxUsingTangem()

    }

}
