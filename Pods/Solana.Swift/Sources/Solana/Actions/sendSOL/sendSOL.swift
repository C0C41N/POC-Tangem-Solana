import Foundation

extension Action {
    public func serializeMessage(
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?,
        allowUnfundedRecipient: Bool = false,
        fromPublicKey: PublicKey,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {
        checkTransaction(
            to: destination,
            amount: amount,
            computeUnitLimit: computeUnitLimit,
            computeUnitPrice: computeUnitPrice,
            allowUnfundedRecipient: allowUnfundedRecipient,
            fromPublicKey: fromPublicKey
        ) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success:
                self.serializedMessage(
                    from: fromPublicKey,
                    to: destination,
                    amount: amount,
                    computeUnitLimit: computeUnitLimit,
                    computeUnitPrice: computeUnitPrice,
                    onComplete: onComplete
                )
            }
        }
    }
    
    public func sendSOL(
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?,
        allowUnfundedRecipient: Bool = false,
        signer: Signer,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        let fromPublicKey = signer.publicKey
        checkTransaction(
            to: destination,
            amount: amount,
            computeUnitLimit: computeUnitLimit,
            computeUnitPrice: computeUnitPrice,
            allowUnfundedRecipient: allowUnfundedRecipient,
            fromPublicKey: fromPublicKey
        ) { result in
            switch result {
            case .failure(let error):
                onComplete(.failure(error))
            case .success:
                self.serializeAndSend(
                    from: fromPublicKey,
                    to: destination,
                    amount: amount,
                    computeUnitLimit: computeUnitLimit,
                    computeUnitPrice: computeUnitPrice,
                    signer: signer,
                    onComplete: onComplete
                )
            }
        }
    }

    fileprivate func checkTransaction(
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?,
        allowUnfundedRecipient: Bool = false,
        fromPublicKey: PublicKey,
        onComplete: @escaping ((Result<Void, Error>) -> Void)
    ) {
        if fromPublicKey.base58EncodedString == destination {
            onComplete(.failure(SolanaError.other("You can not send tokens to yourself")))
            return
        }

        // check
        if allowUnfundedRecipient {
            onComplete(.success(()))
        } else {
            self.api.getAccountInfo(account: destination, decodedTo: EmptyInfo.self) { resultInfo in
                if case Result.failure( let error) = resultInfo {
                    if let solanaError = error as? SolanaError,
                       case SolanaError.couldNotRetriveAccountInfo = solanaError {
                        // let request through
                    } else {
                        onComplete(.failure(error))
                        return
                    }
                }
                
                guard case Result.success(let info) = resultInfo else {
                    onComplete(.failure(SolanaError.couldNotRetriveAccountInfo))
                    return
                }
                
                guard info.owner == PublicKey.programId.base58EncodedString else {
                    onComplete(.failure(SolanaError.other("Invalid account info")))
                    return
                }
                
                onComplete(.success(()))
            }
        }
    }
    
    fileprivate func serializedMessage(
        from fromPublicKey: PublicKey,
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?,
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {
        let instructionsResult = sendSolInstructions(from: fromPublicKey, to: destination, amount: amount, computeUnitLimit: computeUnitLimit, computeUnitPrice: computeUnitPrice)
        
        let instructions: [TransactionInstruction]
        switch instructionsResult {
        case .success(let array):
            instructions = array
        case .failure(let error):
            onComplete(.failure(error))
            return
        }
        
        self.serializeTransaction(
            instructions: instructions,
            signers: [],
            feePayer: fromPublicKey,
            mode: .serializeOnly
        ) {
            onComplete($0)
        }
    }
    
    fileprivate func serializeAndSend(
        from fromPublicKey: PublicKey,
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?,
        signer: Signer,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        let instructionsResult = sendSolInstructions(from: fromPublicKey, to: destination, amount: amount, computeUnitLimit: computeUnitLimit, computeUnitPrice: computeUnitPrice)

        let instructions: [TransactionInstruction]
        switch instructionsResult {
        case .success(let array):
            instructions = array
        case .failure(let error):
            onComplete(.failure(error))
            return
        }
        
        self.serializeAndSendWithFee(
            instructions: instructions,
            signers: [signer]
        ) {
            onComplete($0)
        }
    }
    
    fileprivate func sendSolInstructions(
        from fromPublicKey: PublicKey,
        to destination: String,
        amount: UInt64,
        computeUnitLimit: UInt32?,
        computeUnitPrice: UInt64?
    ) -> Result<[TransactionInstruction], Error> {
        guard let to = PublicKey(string: destination) else {
            return .failure(SolanaError.invalidPublicKey)
        }
        
        var instructions = [TransactionInstruction]()
        
        if let computeUnitLimit {
            instructions.append(ComputeBudgetProgram.setComputeUnitLimitInstruction(units: computeUnitLimit))
        }
        
        if let computeUnitPrice {
            instructions.append(ComputeBudgetProgram.setComputeUnitPriceInstruction(microLamports: computeUnitPrice))
        }
        
        let transferInstruction = SystemProgram.transferInstruction(
            from: fromPublicKey,
            to: to,
            lamports: amount
        )
        instructions.append(transferInstruction)
        
        return .success(instructions)
    }
}

extension ActionTemplates {
    public struct SendSOL: ActionTemplate {
        public init(amount: UInt64, computeUnitLimit: UInt32?, computeUnitPrice: UInt64?, destination: String, signer: Signer) {
            self.amount = amount
            self.computeUnitLimit = computeUnitLimit
            self.computeUnitPrice = computeUnitPrice
            self.destination = destination
            self.signer = signer
        }

        public typealias Success = TransactionID
        public let amount: UInt64
        public let computeUnitLimit: UInt32?
        public let computeUnitPrice: UInt64?
        public let destination: String
        public let signer: Signer

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.sendSOL(to: destination, amount: amount, computeUnitLimit: computeUnitLimit, computeUnitPrice: computeUnitPrice, signer: signer, onComplete: completion)
        }
    }
}
