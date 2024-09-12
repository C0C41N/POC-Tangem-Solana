import Foundation

public enum SerializationMode {
    case serializeOnly
    case serializeAndSign
}

extension Action {
    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Signer],
        feePayer: PublicKey? = nil,
        mode: SerializationMode,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {

        guard let feePayer = feePayer ?? signers.first?.publicKey else {
            onComplete(.failure(SolanaError.invalidRequest(reason: "Fee-payer not found")))
            return
        }

        let getRecentBlockhashRequest: (Result<String, Error>) -> Void = { result in
            switch result {
            case .success(let recentBlockhash):
                let queue = DispatchQueue.global()
                queue.async {
                    let transaction = Transaction(
                        feePayer: feePayer,
                        instructions: instructions,
                        recentBlockhash: recentBlockhash
                    )

                    switch mode {
                    case .serializeOnly:
                        let serializedMessage = transaction
                            .serializeMessage()
                            .map { $0.base64EncodedString() }
                        onComplete(serializedMessage)
                    case .serializeAndSign:
                        transaction.sign(signers: signers, queue: queue) { result in
                            result
                                .flatMap { transaction.serialize() }
                                .flatMap {
                                    let base64 = $0.bytes.toBase64()
                                    return .success(base64)
                                }
                                .onSuccess { onComplete(.success($0)) }
                                .onFailure { onComplete(.failure($0)) }
                        }
                    }
                }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }

        if let recentBlockhash = recentBlockhash {
            getRecentBlockhashRequest(.success(recentBlockhash))
        } else {
            // Disable need retry for send only
            let needRetry = mode == .serializeOnly
            self.api.getLatestBlockhash(enableСontinuedRetry: needRetry, onComplete: getRecentBlockhashRequest)
        }
    }
}

extension ActionTemplates {
    public struct SerializeTransaction: ActionTemplate {
        public init(instructions: [TransactionInstruction], signers: [Account], recentBlockhash: String? = nil, feePayer: PublicKey? = nil, mode: SerializationMode) {
            self.instructions = instructions
            self.recentBlockhash = recentBlockhash
            self.signers = signers
            self.feePayer = feePayer
            self.mode = mode
        }

        public typealias Success = String

        public let instructions: [TransactionInstruction]
        public let recentBlockhash: String?
        public let signers: [Account]
        public let feePayer: PublicKey?
        public let mode: SerializationMode

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<String, Error>) -> Void) {
            actionClass.serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers, feePayer: feePayer, mode: mode, onComplete: completion)
        }
    }
}
