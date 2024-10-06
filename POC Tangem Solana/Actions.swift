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

            guard result.success, let card = result.value else {
                print("Failed to scan card: \(result.error!)")
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

            guard result.success, let signature = result.value else {
                print("Signing failed: \(result.error!)")
                return
            }

            print("Signature: \(signature)")

        }

    }

    func createWallets() {

        Task {

            let startSessionResult = await tangemSdk.startSessionAsync(cardId: nil)

            guard startSessionResult.success, let session = startSessionResult.value else {
                print("Start Session failed: \(startSessionResult.error!)")
                return
            }

            let scan = ScanTask()
            let scanResult = await scan.runAsync(in: session)

            guard scanResult.success, let card = scanResult.value else {
                print("ScanTask failed: \(scanResult.error!)")
                session.stop()
                return
            }

            print(card.json)

            let scan2 = ScanTask()
            let scanResult2 = await scan2.runAsync(in: session)

            guard scanResult2.success, let card2 = scanResult2.value else {
                print("ScanTask2 failed: \(scanResult2.error!)")
                session.stop()
                return
            }

            print(card2.json)

            session.stop()

        }

    }

}
