//
//  Blockchain.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import Solana
import TangemSdk

class Blockchain {

    private let tangemSdk = TangemProvider.getTangemSdk()

    func trxSolana() {

        let endpoint = RPCEndpoint.devnetSolana
        let router = NetworkingRouter(endpoint: endpoint)
        let solana = Solana(router: router)

        let sol = 0.00001                                                               // amount to transfer
        let tangemPublicKeyBase58 = "EPFHi2vvpVeuuZU3TDXYxFfwEGxZhceL1h2tmia6wLgh"      // main public key
        let recipientPublicKeyBase58 = "96fuzKSqE7tCYY3sm6SxfujhrRy5JpN3gkQqAWnsB8mm"   // phantom public key

        guard let tangemPublicKey = PublicKey(string: tangemPublicKeyBase58) else {
            print("Invalid public key")
            return
        }

        guard let recepientPublicKey = PublicKey(string: recipientPublicKeyBase58) else {
            print("Invalid public key")
            return
        }

        Task {

            do {

                // check balance

                let tangemAccInfo = try await solana.api.getAccountInfo(
                    account: tangemPublicKeyBase58,
                    decodedTo: AccountInfo.self
                )

                print("Tangem Balance: \(LamportsConverter(lamports: tangemAccInfo.lamports).sol)")

                // creating transaction

                let instruction = SystemProgram.transferInstruction(
                    from: tangemPublicKey,
                    to: recepientPublicKey,
                    lamports: LamportsConverter(sol: sol).lamports
                )

                let blockhash = try await solana.api.getLatestBlockhash()

                print("Latest Blockhash: \(blockhash)")

                var transaction = Transaction(
                    feePayer: tangemPublicKey,
                    instructions: [instruction],
                    recentBlockhash: blockhash
                )

                // signing transaction

                let tangemSigner = TangemSigner(publicKey: tangemPublicKey)

                guard case .success = transaction.sign(signers: [tangemSigner]) else {
                    print("signing failed!")
                    return
                }

                print("signing successful!")

                guard case .success(let serializedTransactionData) = transaction.serialize() else {
                    print("Failed to serialize transaction!")
                    return
                }

                let serializedTransactionBase64 = serializedTransactionData.base64EncodedString()

                // broadcasting transaction

                let transactionId = try await solana.api.sendTransaction(serializedTransaction: serializedTransactionBase64)

                print("Transaction ID: \(transactionId)")

            } catch {

                print("An error occurred: \(error)")

            }

        }

    }

    func signTronHash() {

        let pubKeyBase58 = "261tNC22med7Yn6pxp5iKfxUF231KXVtfjEYmsPbWqGjx"
        let trxId = "69fce9dcf2246d8f1065a36af872a3bcd845810343ee810bf66254951331a9bf"

        let pubKeyData = Data(Base58.decode(pubKeyBase58))
        let trxIdData = Data(hexString: trxId)

        tangemSdk.sign(hash: trxIdData, walletPublicKey: pubKeyData) { result in

            switch result {

                case .success(let response):
                    print("Signature: \(response.signature.hexString)")

                case .failure(let error):
                    print("signing failed!")

            }

        }

    }

}
