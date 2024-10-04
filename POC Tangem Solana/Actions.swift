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
    private let tangemSdk = TangemProvider.getTangemSdk()
    
    func scan() {
        
        tangemSdk.scanCard(initialMessage: Message(header: "Scan Card", body: "Tap Tangem Card to learn more")) { result in
            
            guard let card = try? result.get() else {
                print("Failed to scan card.")
                return
            }
            
            print(card.json)
            
            card.wallets.enumerated().forEach { index, wallet in
                print("Wallet \(index) curve [\(wallet.curve.rawValue)] publicKeyBase58: [\(wallet.publicKey.base58EncodedString)] publicKey: [\(wallet.publicKey.hexString)]")
            }
            
        }
        
    }

    func trxSolana() {
        
        print("initiating solana trx")
        blockchain.trxSolana()
        
    }
    
    func signTronHash() {
        
        blockchain.signTronHash()
        
    }
    
}
