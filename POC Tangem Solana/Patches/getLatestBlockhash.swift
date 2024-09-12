//
//  getLatestBlockhash.swift
//  POC Tangem Solana
//
//  Created by Ali M. on 12/09/2024.
//

import Foundation
import Solana
import struct Solana_Swift.LatestBlockhash

public extension Api {
    func getLatestBlockhash(commitment: Commitment? = nil, onComplete: @escaping(Result<String, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)]) { (result: Result<Rpc<LatestBlockhash?>, Error>) in
            switch result {
            case .success(let rpc):
                guard let value = rpc.value else {
                    onComplete(.failure(SolanaError.nullValue))
                    return
                }
                guard let blockhash = value.blockhash else {
                    onComplete(.failure(SolanaError.blockHashNotFound))
                    return
                }
                onComplete(.success(blockhash))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Api {
    /// Returns a recent block hash from the ledger, and a fee schedule that can be used to compute the cost of submitting a transaction using it.
    /// - Parameters:
    ///   - commitment: The commitment describes how finalized a block is at that point in time (finalized, confirmed, processed)
    /// - Returns: A Hash as base-58 encoded string
    func getLatestBlockhash(commitment: Commitment? = nil) async throws -> String {
        try await withCheckedThrowingContinuation { c in
            self.getLatestBlockhash(commitment: commitment, onComplete: c.resume(with:))
        }
    }
}

public extension ApiTemplates {
    struct GetLatestBlockhash: ApiTemplate {
        public init(commitment: Commitment? = nil) {
            self.commitment = commitment
        }
        
        public let commitment: Commitment?
        
        public typealias Success = String
        
        public func perform(withConfigurationFrom apiClass: Api, completion: @escaping (Result<Success, Error>) -> Void) {
            apiClass.getLatestBlockhash(commitment: commitment, onComplete: completion)
        }
    }
}

