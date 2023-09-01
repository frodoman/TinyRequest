
import Foundation

public extension TinyServiceProtocol {
    func asyncDataResponse() async throws -> (Data, URLResponse)   {
        let url = try prepareURL()
        let request = prepareRequest(url: url)
        
        return try await request.dataResponse()
    }
    
    func asyncObject<T>(type: T.Type) async throws -> T where T: Decodable {
        let url = try prepareURL()
        let request = prepareRequest(url: url)
        return try await request.objectResponse(type: T.self)
    }
}
