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

            for wallet in card.wallets {
                let curve = wallet.curve.rawValue
                let pubKey = wallet.publicKey.base58EncodedString
                print("Wallet \(curve) | \(pubKey)")
            }

            session.stop()

        }

    }

    func sign(unsignedHex: String, pubKeyBase58: String) {

        Task {
            
            let startSessionResult = await tangemSdk.startSessionAsync(cardId: nil)

            guard startSessionResult.success, let session = startSessionResult.value else {
                print("Start Session failed: \(startSessionResult.error!)")
                return
            }

            let pubKeyData = pubKeyBase58.base58DecodedData
            let hashData = Data(hexString: unsignedHex)

            let sign = SignCommand(hashes: [hashData], walletPublicKey: pubKeyData)
            let signResult = await sign.runAsync(in: session)

            guard signResult.success, let response = signResult.value else {
                print("SignCommand failed: \(signResult.error!)")
                session.stop()
                return
            }

            let signature = response.signatures[0].hexString
            print("Signed Hex | \(signature)")

            session.stop()

        }

    }

    func purgeAllWallets() {

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

            for wallet in card.wallets {
                let purge = PurgeWalletCommand(publicKey: wallet.publicKey)
                let purgeResult = await purge.runAsync(in: session)

                guard purgeResult.success else {
                    print("PurgeWalletCommand failed: \(purgeResult.error!)")
                    session.stop()
                    return
                }

                let curve = wallet.curve.rawValue
                let pubKey = wallet.publicKey.base58EncodedString

                print("Purged wallet \(curve) | \(pubKey)")
            }

            session.stop()

        }

    }
    
    func createAllWallets() {

        Task {

            let startSessionResult = await tangemSdk.startSessionAsync(cardId: nil)

            guard startSessionResult.success, let session = startSessionResult.value else {
                print("Start Session failed: \(startSessionResult.error!)")
                return
            }

            let curves: [EllipticCurve] = [.secp256k1, .ed25519, .bls12381_G2_AUG, .bip0340, .ed25519_slip0010]

            for curve in curves {
                let createWallet = CreateWalletTask(curve: curve)
                let createWalletResult = await createWallet.runAsync(in: session)

                guard createWalletResult.success, let response = createWalletResult.value else {
                    print("CreateWalletTask failed: \(createWalletResult.error!)")
                    session.stop()
                    return
                }

                print("Created wallet \(curve.rawValue) | \(response.wallet.publicKey.base58EncodedString)")
            }

            session.stop()

        }

    }

}
