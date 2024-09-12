import Foundation

public extension Api {
    func getRecentPrioritizationFees(accounts: [String], onComplete: @escaping(Result<[RecentPrioritizationFee], Error>) -> Void) {
        router.request(parameters: [accounts, RequestConfiguration()]) { (result: Result<[RecentPrioritizationFee], Error>) in
            switch result {
            case .success(let array):
                onComplete(.success(array))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
