//
//  Blockchain.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 11/09/2024.
//

import Foundation
import Solana

class Blockchain {
    
    private let tangemSdk = TangemProvider().getTangemSdk()
    
    func trxUsingTangem() {
        
        let endpoint = RPCEndpoint.devnetSolana
        let router = NetworkingRouter(endpoint: endpoint)
        let solana = Solana(router: router)

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
        
        let lamports: UInt64 = 1_000_000 // 0.001 SOL
        
        Task {
            
            do {

                // check balance
                
                let tangemAccInfo = try await solana.api.getAccountInfo(
                    account: tangemPublicKeyBase58,
                    decodedTo: AccountInfo.self
                )

                print("Tangem Balance: \(tangemAccInfo.lamports)")

                let recipientAccInfo = try await solana.api.getAccountInfo(
                    account: recipientPublicKeyBase58,
                    decodedTo: AccountInfo.self
                )

                print("Recipient Balance: \(recipientAccInfo.lamports)")

                // creating transaction

                let instruction = SystemProgram.transferInstruction(
                    from: tangemPublicKey,
                    to: recepientPublicKey,
                    lamports: lamports
                )

                print("Before making api call")

                let blockhash = try await solana.api.getLatestBlockhash()

                print("Recent Blockhash: \(blockhash)")
                
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
                
                print("serializedTransactionBase64: \(serializedTransactionBase64)")
                
                // broadcasting transaction
  
                let transactionId = try await solana.api.sendTransaction(serializedTransaction: serializedTransactionBase64)
                
                print("Transaction successful. ID: \(transactionId)")
                
            } catch {
                
                print("An error occurred: \(error)")
                
            }
            
        }
        
    }
    
    func xyz() {
        
        let secretKeyBase58 = "m2zWUh5MkVzn3aCYCxr78rTJn2z3pykcjDiStKPLxBiDcomx46BubkbYUHRmCqpxu8fcP7Tj4xit3F2w6Jfg83R"
        let secretKeyData = Data(Base58.decode(secretKeyBase58))
        
        guard let account = HotAccount(secretKey: secretKeyData) else { return }
        
        let endpoint = RPCEndpoint.devnetSolana
        
        let router = NetworkingRouter(endpoint: endpoint)
        let solana = Solana(router: router)
        
        let recipientPublicKey = "96fuzKSqE7tCYY3sm6SxfujhrRy5JpN3gkQqAWnsB8mm"
        
        guard let toPublicKey = PublicKey(string: recipientPublicKey) else {
            print("Invalid public key")
            return
        }
        
        let lamports: UInt64 = 1_000_000 // 0.001 SOL
        
        Task {
            
            do {
                
                let balance = try await solana.api.getBalance(account: account.publicKey.base58EncodedString)
                print("Balance: \(balance)")
                
                let acc = try await solana.api.getAccountInfo(account: recipientPublicKey,decodedTo: AccountInfo.self)
                print("Recipient Balance: \(acc.lamports)")
                
                let instruction = SystemProgram.transferInstruction(
                    from: account.publicKey,
                    to: toPublicKey,
                    lamports: lamports
                )
                
                print("Before making api call")
                
                let blockhash = try await solana.api.getLatestBlockhash()
                
                print("Recent Blockhash: \(blockhash)")
                
                var transaction = Transaction(
                    feePayer: account.publicKey,
                    instructions: [instruction],
                    recentBlockhash: blockhash
                )
                
                guard case .success = transaction.sign(signers: [account]) else {
                    print("signing failed!")
                    return
                }
                
                guard case .success(let serializedTransactionData) = transaction.serialize() else {
                    print("Failed to serialize transaction!")
                    return
                }
                
                let serializedTransactionBase64 = serializedTransactionData.base64EncodedString()
                
                print("serializedTransactionBase64: \(serializedTransactionBase64)")
  
                let transactionId = try await solana.api.sendTransaction(serializedTransaction: serializedTransactionBase64)
                
                print("Transaction successful. ID: \(transactionId)")
                
            } catch {
                
                print("An error occurred: \(error)")
                
            }
            
        }
        
    }
    
}
