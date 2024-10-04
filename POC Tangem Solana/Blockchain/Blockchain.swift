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

        let tangemPublicKey = Base58.decode("261tNC22med7Yn6pxp5iKfxUF231KXVtfjEYmsPbWqGjx")
        
        let hash = "8300faae11f235eeef2c1dd66026df91304d70b6c27730a96f9b45b83d46b5d9"
        
        tangemSdk.sign(hash: Data(hexString: hash), walletPublicKey: Data(tangemPublicKey.bytes)) { result in
            switch result {
            case .success(let response):
                print("Signature: \(response.signature.hexString)")
                
                do {
                    let signature = try Secp256k1Signature(with: response.signature)
                    let unmarshalledSignature = try signature.unmarshal(with: Data(tangemPublicKey.bytes).dropFirst(), hash: Data(hexString: hash))
                    
                    guard unmarshalledSignature.v.count == 1 else {
                        print("Error: unmarshalledSignature.v.count == 1")
                        return
                    }
                    
                    let recoveryId = unmarshalledSignature.v[0] - 27
                    
                    guard recoveryId >= 0, recoveryId <= 3 else {
                        print("Error: recoveryId >= 0, recoveryId <= 3")
                        return
                    }
                    
                    let finalSignature = unmarshalledSignature.r + unmarshalledSignature.s + Data(recoveryId)
                    
                    print("Final Signature: \(finalSignature.hexString)")
                }
                catch {
                    print("Error unmarshalling signature")
                }
                
            case .failure(let _error):
                print("signing failed!")
            }

        }

    }
    
}
