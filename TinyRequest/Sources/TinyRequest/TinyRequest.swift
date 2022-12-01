
import Foundation
import Combine

public protocol TinyRequestProtocol: AnyObject {
    
    init(url: URL)
    
    func set(method: String) -> TinyRequestProtocol
    
    func set(header: [String: String]) -> TinyRequestProtocol
    func set<T: Encodable>(header object: T) -> TinyRequestProtocol
    
    func set(body: Data) -> TinyRequestProtocol
    func set<T: Encodable>(body object: T) -> TinyRequestProtocol
    
    func dataPublisher() -> AnyPublisher<Data, Error>
    func objectPublisher<T: Decodable>(returnType: T.Type) -> AnyPublisher<T, Error>
}

public class TinyRequest: TinyRequestProtocol {
    
    private var request: URLRequest
    private let session: URLSession
    private let decoder: JSONDecoder
    
    public required convenience init(url: URL) {
        self.init(request: URLRequest(url: url),
                  session: .shared,
                  decoder: JSONDecoder())
    }
    
    public init(request: URLRequest,
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
    
    public func set<T>(header object: T) -> TinyRequestProtocol where T : Encodable {
        if let dic = object.toDictionary() as? [String: String] {
            return set(header: dic)
        }
        return self
    }
    
    public func set(body: Data) -> TinyRequestProtocol {
        request.httpBody = body
        return self
    }
    
    public func set<T>(body object: T) -> TinyRequestProtocol where T : Encodable {
        if let data = object.toData() {
            return set(body: data)
        }
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
