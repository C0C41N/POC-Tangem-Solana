import Foundation

extension Action {

    public func getOrCreateAssociatedTokenAccount(
        owner: PublicKey,
        tokenMint: PublicKey,
        tokenProgramId: PublicKey,
        onComplete: @escaping (Result<(transactionId: TransactionID?, associatedTokenAddress: PublicKey), Error>) -> Void
    ) {
        guard case let .success(associatedAddress) = PublicKey.associatedTokenAddress(
            walletAddress: owner,
            tokenMintAddress: tokenMint,
            tokenProgramId: tokenProgramId
        ) else {
            onComplete(.failure(SolanaError.other("Could not create associated token account")))
            return
        }

        api.getAccountInfo(
            account: associatedAddress.base58EncodedString,
            decodedTo: AccountInfo.self
        ) { acountInfoResult in
            switch acountInfoResult {
            case .success(let info):
                if info.owner == tokenProgramId.base58EncodedString &&
                    info.data.value != nil {
                    onComplete(.success((transactionId: nil, associatedTokenAddress: associatedAddress)))
                    return
                }
                self.createAssociatedTokenAccount(
                    for: owner,
                    tokenMint: tokenMint,
                    tokenProgramId: tokenProgramId
                ) { createAssociatedResult in
                    switch createAssociatedResult {
                    case .success(let transactionId):
                        onComplete(.success((transactionId: transactionId, associatedTokenAddress: associatedAddress)))
                        return
                    case .failure(let error):
                        onComplete(.failure(error))
                        return
                    }
                }
            case .failure(let error):
                onComplete(.failure(error))
                return
            }
        }
    }

    public func createAssociatedTokenAccount(
        for owner: PublicKey,
        tokenMint: PublicKey,
        tokenProgramId: PublicKey,
        payer: Account? = nil,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        // get account
        guard let payer = try? payer ?? auth.account.get() else {
            return onComplete(.failure(SolanaError.unauthorized))
        }

        guard case let .success(associatedAddress) = PublicKey.associatedTokenAddress(
                walletAddress: owner,
                tokenMintAddress: tokenMint,
                tokenProgramId: tokenProgramId
            ) else {
                onComplete(.failure(SolanaError.other("Could not create associated token account")))
                return
            }

            // create instruction
            let instruction = AssociatedTokenProgram
                .createAssociatedTokenAccountInstruction(
                    programId: tokenProgramId,
                    mint: tokenMint,
                    associatedAccount: associatedAddress,
                    owner: owner,
                    payer: payer.publicKey
                )

            // send transaction
            serializeAndSendWithFee(
                instructions: [instruction],
                signers: [payer]
            ) { serializeResult in
                switch serializeResult {
                case .success(let reesult):
                    onComplete(.success(reesult))
                case .failure(let error):
                    onComplete(.failure(error))
                    return
                }
            }
    }
}

extension ActionTemplates {

    public struct CreateAssociatedTokenAccountAction: ActionTemplate {
        public init(owner: PublicKey, tokenMint: PublicKey, tokenProgramId: PublicKey, payer: Account?) {
            self.owner = owner
            self.tokenMint = tokenMint
            self.tokenProgramId = tokenProgramId
            self.payer = payer
        }

        public typealias Success = TransactionID
        public let owner: PublicKey
        public let tokenMint: PublicKey
        public let tokenProgramId: PublicKey
        public let payer: Account?

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.createAssociatedTokenAccount(
                for: owner,
                   tokenMint: tokenMint,
                   tokenProgramId: tokenProgramId,
                   payer: payer,
                   onComplete: completion
            )
        }
    }

    public struct GetOrCreateAssociatedTokenAccountAction: ActionTemplate {
        public init(owner: PublicKey, tokenMint: PublicKey, tokenProgramId: PublicKey) {
            self.owner = owner
            self.tokenMint = tokenMint
            self.tokenProgramId = tokenProgramId
        }

        public typealias Success = (transactionId: TransactionID?, associatedTokenAddress: PublicKey)
        public let owner: PublicKey
        public let tokenMint: PublicKey
        public let tokenProgramId: PublicKey

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<Success, Error>) -> Void) {
            actionClass.getOrCreateAssociatedTokenAccount(owner: owner, tokenMint: tokenMint, tokenProgramId: tokenProgramId, onComplete: completion)
        }
    }
}
