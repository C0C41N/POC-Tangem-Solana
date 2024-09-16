//
//  TangemSigner.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 12/09/2024.
//

import Foundation
import Solana

class TangemSigner: Signer {
    private let tangemSdk = TangemProvider().getTangemSdk()
    
    var publicKey: PublicKey
    
    init(publicKey: PublicKey) {
        self.publicKey = publicKey
    }
    
    func sign(serializedMessage: Data) throws -> Data {
        var resultData: Data?
        var resultError: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        tangemSdk.sign(hash: serializedMessage, walletPublicKey: publicKey.data) { result in
            switch result {
            case .success(let response):
                resultData = response.signature
            case .failure(let error):
                resultError = error
            }
            semaphore.signal()
        }
        
        // Wait for the async call to complete
        semaphore.wait()
        
        // If an error occurred, throw it
        if let error = resultError {
            throw error
        }
        
        // If no data was returned, throw an unexpected error
        guard let signatureData = resultData else {
            throw NSError(domain: "TangemSdk", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign the message"])
        }
        
        return signatureData
    }
    
}
