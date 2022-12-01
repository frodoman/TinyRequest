
import Foundation
import Combine

public protocol TinyRequestProtocol: AnyObject {
    
    init(url: URL)
    
    func set(method: String) -> TinyRequestProtocol
    func set(header: [String: String]) -> TinyRequestProtocol
    func set(body: Data) -> TinyRequestProtocol
    
    func dataPublisher() -> AnyPublisher<Data, Error>
    func objectPublisher<T: Decodable>(returnType: T.Type) -> AnyPublisher<T, Error>
}

public class TinyRequest: TinyRequestProtocol {
    
    private var url: URL
    private var request: URLRequest
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public required convenience init(url: URL) {
        self.init(url: url,
                  session: .shared,
                  decoder: JSONDecoder())
    }
    
    public init(url: URL,
                session: URLSession,
                decoder: JSONDecoder) {
        self.url = url
        self.session = session
        self.decoder = decoder
        self.request = URLRequest(url: url)
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
    
    public func set(body: Data) -> TinyRequestProtocol {
        
        request.httpBody = body
        
        return self
    }
    
    public func dataPublisher() -> AnyPublisher<Data, Error> {
        session.dataTaskPublisher(for: request)
                      .tryMap { data, response -> Data in
                          if let httpResponse = response as? HTTPURLResponse,
                                httpResponse.statusCode != 200 {
                                    throw TinyErrors.invalidResponse(response)
                          }
                          return data
                      }
                      .eraseToAnyPublisher()
    }
    
    public func objectPublisher<T>(returnType: T.Type) -> AnyPublisher<T, Error> where T: Decodable {
        dataPublisher()
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
