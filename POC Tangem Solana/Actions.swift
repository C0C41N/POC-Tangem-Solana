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
        
        Task {

            let initialMessage = Message(header: "Scan Card", body: "Tap Tangem Card to learn more")
            let result = await tangemSdk.scanAsync(initialMessage: initialMessage)
            
            guard case .success(let card) = result else {
                if case .failure(let error) = result {
                    print("Failed to scan card: \(error.localizedDescription)")
                }
                return
            }

            print(card.json)

            card.wallets.enumerated().forEach { index, wallet in
                let curve = wallet.curve.rawValue
                let pubKey = wallet.publicKey.base58EncodedString
                print("Wallet \(index) curve [\(curve)] publicKeyBase58: [\(pubKey)]")
            }

        }
        
    }
    
    func sign(unsignedHex: String, pubKeyBase58: String) {
        
        Task {

            let pubKeyData = pubKeyBase58.base58DecodedData
            let hashData = Data(hexString: unsignedHex)

            let result = await tangemSdk.signAsync(hash: hashData, walletPublicKey: pubKeyData)
            
            guard case .success(let signature) = result else {
                if case .failure(let error) = result {
                    print("Signing failed: \(error)")
                }
                return
            }

            print("Signature: \(signature)")
            
        }
        
    }
    
    func createWallets() {

        Task {

            let startSessionResult = await tangemSdk.startSessionAsync(cardId: nil)
            
            guard case .success(let session) = startSessionResult else {
                if case .failure(let error) = startSessionResult {
                    print("Start Session failed: \(error)")
                }
                return
            }
            
            let scan = ScanTask()
            let scanResult = await scan.runAsync(in: session)
            
            guard case .success(let card) = scanResult else {
                if case .failure(let error) = scanResult {
                    print("Start Session failed: \(error)")
                }
                session.stop()
                return
            }
            
            print(card.json)
            
            let scan2 = ScanTask()
            let scanResult2 = await scan2.runAsync(in: session)
            
            guard case .success(let card2) = scanResult2 else {
                if case .failure(let error) = scanResult2 {
                    print("Start Session failed: \(error)")
                }
                session.stop()
                return
            }
            
            print(card2.json)
            
            session.stop()

        }

    }
    
}
