
import Foundation
import Combine

public typealias TinyOutput = (data: Data, response: URLResponse)

public protocol TinyRequestProtocol: AnyObject {
    
    init(url: URL)
    
    func set(method: String) -> TinyRequestProtocol
    func set(header: [String: String]) -> TinyRequestProtocol
    func setHeader<T: Encodable>(object: T) -> TinyRequestProtocol
    
    func set(body: Data) -> TinyRequestProtocol
    func setBody<T: Encodable>(object: T) -> TinyRequestProtocol
    
    func outputResponsePublisher() -> AnyPublisher<TinyOutput, URLError>
    func dataPublisher() -> AnyPublisher<Data, URLError>
    func responsePublisher() -> AnyPublisher<URLResponse, URLError>
    func objectPublisher<T: Decodable>(type: T.Type) -> AnyPublisher<T, Error>
}

public class TinyRequest: TinyRequestProtocol {
    
    private var request: URLRequestProtocol
    private var session: URLSession
    private var decoder: JSONDecoder
    
    public required convenience init(url: URL) {
        self.init(request: URLRequest(url: url),
                  session: .shared,
                  decoder: JSONDecoder())
    }
    
    public init(request: URLRequestProtocol,
                session: URLSession,
                decoder: JSONDecoder) {
        self.session = session
        self.decoder = decoder
        self.request = request
    }
    
    public func set(method: String) -> TinyRequestProtocol {
        request.httpMethod = method
        return self
    }

    public func set(header: [String: String]) -> TinyRequestProtocol {
        request.allHTTPHeaderFields?.removeAll()
        for (key, value) in header {
            request.addValue(value, forHTTPHeaderField: key)
        }
        return self
    }
    
    public func setHeader<T>(object: T) -> TinyRequestProtocol where T : Encodable {
        if let dic = object.toDictionary() as? [String: String] {
            return set(header: dic)
        }
        return self
    }
    
    public func set(body: Data) -> TinyRequestProtocol {
        request.httpBody = body
        return self
    }
    
    public func setBody<T>(object: T) -> TinyRequestProtocol where T : Encodable {
        if let data = object.toData() {
            return set(body: data)
        }
        return self
    }
    
    public func outputResponsePublisher() -> AnyPublisher<TinyOutput, URLError> {
        guard let urlRequest = request as? URLRequest else {
            return Fail(error: URLError(.cannotConnectToHost)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
                .eraseToAnyPublisher()
    }
    
    public func dataPublisher() -> AnyPublisher<Data, URLError> {
        outputResponsePublisher()
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    public func objectPublisher<T>(type: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        outputResponsePublisher()
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    public func responsePublisher() -> AnyPublisher<URLResponse, URLError> {
        outputResponsePublisher()
            .map(\.response)
            .eraseToAnyPublisher()
    }
}
