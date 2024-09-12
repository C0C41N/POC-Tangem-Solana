import Foundation

public extension Api {
    func getLatestBlockhash(commitment: Commitment? = nil, enableСontinuedRetry: Bool = true, onComplete: @escaping(Result<String, Error>) -> Void) {
        router.request(parameters: [RequestConfiguration(commitment: commitment)], enableСontinuedRetry: enableСontinuedRetry) { (result: Result<Rpc<LatestBlockhash?>, Error>) in
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
