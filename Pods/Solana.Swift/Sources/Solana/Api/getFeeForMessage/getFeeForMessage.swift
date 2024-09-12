//
//  getFeeForMessage.swift
//  Solana.Swift
//
//  Created by Andrey Chukavin on 14.03.2024.
//

import Foundation

public extension Api {
    func getFeeForMessage(message: String, onComplete: @escaping(Result<FeeForMessageResult, Error>) -> Void) {
        router.request(parameters: [message, RequestConfiguration(commitment: "processed")]) { (result: Result<FeeForMessageResult, Error>) in
            onComplete(result)
        }
    }
}
