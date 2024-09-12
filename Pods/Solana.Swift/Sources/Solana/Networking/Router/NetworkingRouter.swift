import Foundation
import Combine

public enum HTTPMethod: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

public enum RPCError: Error {
    case httpError
    case httpErrorCode(Int)
    case invalidResponseNoData
    case invalidResponse(ResponseError)
    case unknownResponse
    case retry
}

public protocol NetworkingRouterSwitchApiLogger {
    func handle(error: Error, currentHost: String, nextHost: String)
    func handle(error message: String)
}

public class NetworkingRouter: SolanaRouter {
    
    public var endpoint: RPCEndpoint {
        endpoints[currentEndpointIndex]
    }
    
    private var host: String? {
        endpoint.url.host
    }
    
    private let urlSession: URLSession
    private let endpoints: [RPCEndpoint]
    private var apiLogger: NetworkingRouterSwitchApiLogger?
    
    private var currentEndpointIndex = 0
    
    // MARK: - Init
    
    public init(endpoints: [RPCEndpoint], session: URLSession = .shared, apiLogger: NetworkingRouterSwitchApiLogger?) {
        self.endpoints = endpoints
        self.urlSession = session
        self.apiLogger = apiLogger
    }
    
    public func request<T: Decodable>(
        method: HTTPMethod = .post,
        bcMethod: String = #function,
        parameters: [Encodable?] = [],
        enableСontinuedRetry: Bool = true,
        onComplete: @escaping (Result<T, Error>) -> Void
    ) {
        let bcMethod = bcMethod.replacingOccurrences(of: "\\([\\w\\s:]*\\)", with: "", options: .regularExpression)
        let url = endpoint.url
        let params = parameters.compactMap {$0}
        let requestAPI = SolanaRequest(method: bcMethod, params: params)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let apiKeyHeaderName = endpoint.apiKeyHeaderName, let apiKeyHeaderValue = endpoint.apiKeyHeaderValue {
            request.setValue(apiKeyHeaderValue, forHTTPHeaderField: apiKeyHeaderName)
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(requestAPI)
        } catch {
            onComplete(.failure(error))
        }
        
        var subscription: AnyCancellable?
        subscription = urlSession.dataTaskPublisher(for: request)
            .tryMap { (data: Data?, response: URLResponse) -> Void in
                guard let httpURLResponse = response as? HTTPURLResponse else {
                    throw RPCError.httpError
                }
                
                switch httpURLResponse.statusCode {
                case 200..<300:
                    break
                default:
                    throw RPCError.httpErrorCode(httpURLResponse.statusCode)
                }
                
                guard let data = data else {
                    throw RPCError.invalidResponseNoData
                }
                
                let decodedResponse = try JSONDecoder().decode(Response<T>.self, from: data)
                
                if let result = decodedResponse.result {
                    onComplete(.success(result))
                    return
                }
                if let responseError = decodedResponse.error {
                    throw RPCError.invalidResponse(responseError)
                } else {
                    throw RPCError.unknownResponse
                }
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                guard case let .failure(error) = completion else {
                    return
                }
                
                self.apiLogger?.handle(error: "Switchable publisher catched error: \(error) host: \(url.host ?? "")")
                
                func retry() {
                    self.request(method: method,
                                  bcMethod: bcMethod,
                                  parameters: parameters,
                                  onComplete: onComplete)
                }
                
                if let solanaError = error as? RPCError,
                   case .retry = solanaError {
                    retry()
                    return
                }
                
                /*
                 'enableСontinuedRetry' flag used for forced shutdown retry cycle, default value - true
                 Do not confuse the order of checking the conditions, because there must be api switching at least once
                 */
                if self.needRetry(for: url.host) && enableСontinuedRetry {
                    if url.host != host {
                        self.apiLogger?.handle(error: error, currentHost: url.host ?? "", nextHost: self.host ?? "")
                    }
                    
                    retry()
                    
                    withExtendedLifetime(subscription) {}
                    return
                }
                
                self.apiLogger?.handle(error: "Failed to send request: \(bcMethod). Error = \(error)")
                onComplete(.failure(error))
            }, receiveValue: { })
    }
    
    private func needRetry(for errorHost: String?) -> Bool {
        if self.host != errorHost {
            return true
        }
        
        currentEndpointIndex += 1
        if currentEndpointIndex < endpoints.count {
            return true
        }
        
        currentEndpointIndex = 0
        return false
    }
}
