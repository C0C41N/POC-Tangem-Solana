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
    private var blockchain = Blockchain()
    private let tangemSdk = TangemProvider().getTangemSdk()
    
    func scan() {
        print("Calling tangemSdk.scan")
        tangemSdk.scanCard(initialMessage: Message(header: "Scan Card", body: "Tap Tangem Card to learn more")) { result in
            if case let .success(card) = result {
                card.wallets.enumerated().forEach { index, wallet in
                    let publicKey = wallet.publicKey.base58EncodedString
                    let publicKeyHex = wallet.publicKey.hexString
                    let derivedKey = wallet.derivedKeys[try! DerivationPath(rawPath:"m/0'/1")]?.publicKey.base58EncodedString
                    let derivedKeyHex = wallet.derivedKeys[try! DerivationPath(rawPath:"m/0'/1")]?.publicKey.hexString
                    print("Wallet \(index) curve [\(wallet.curve.rawValue)] publicKey: [\(publicKey)]")
                    print("Wallet \(index) curve [\(wallet.curve.rawValue)] publicKeyHex: [\(publicKeyHex)]")
                    print("Wallet \(index) curve [\(wallet.curve.rawValue)] derivedKey: [\(derivedKey)]")
                    print("Wallet \(index) curve [\(wallet.curve.rawValue)] derivedKeyHex: [\(derivedKeyHex)]")
                }
            }
        }
    }
    
    func trx() {
        print("HEYY TRX was pressed!")
        blockchain.trxUsingTangem()
    }
}
