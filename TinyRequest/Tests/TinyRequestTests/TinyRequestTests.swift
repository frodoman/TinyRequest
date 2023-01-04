import XCTest
import Combine
@testable import TinyRequest

final class TinyRequestTests: XCTestCase {
    
    var cancllables: [AnyCancellable] = []
    
    func testExample() throws {
        
        let url = try getMockURL()
        let exp = expectation(description: "Expecting [Person] object")
        
        TinyRequest(url: url)
            .set(method: "GET")
            .objectPublisher(type: [Person].self)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { people in
                XCTAssertFalse(people.isEmpty)
                exp.fulfill()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
    }
    
    private func getMockURL() throws -> URL {
        guard let url = Bundle.module.url(forResource: "people", withExtension: "json") else {
            throw TestError.fileNotFound("people.json")
        }
        return url
    }
    
    func testSetMethod() throws {
        let mockRequest = MockURLRequest()
        let tinyRequest = TinyRequest(request: mockRequest,
                                      session: .shared,
                                      decoder: JSONDecoder())
        
        _ = tinyRequest.set(method: "ANY")
        
        XCTAssertEqual(mockRequest.httpMethod, "ANY")
    }
    
    func testSetHeader() throws {
        let mockRequest = MockURLRequest()
        let tinyRequest = TinyRequest(request: mockRequest,
                                      session: .shared,
                                      decoder: JSONDecoder())
        _ = tinyRequest.set(header: ["header-key": "h-value"])
        
        XCTAssertEqual(mockRequest.allHTTPHeaderFields!["header-key"], "h-value")
    }
    
    func testSetHeaderObject() throws {
        let header = ["header": "h-value"]
        let mockRequest = MockURLRequest()
        let tinyRequest = TinyRequest(request: mockRequest,
                                      session: .shared,
                                      decoder: JSONDecoder())
        
        _ = tinyRequest.setHeader(object: header)
        
        XCTAssertEqual(mockRequest.allHTTPHeaderFields!["header"], "h-value")
    }
    
    func testSetBody() throws {
        
    }
    
    func testSetBodyObject() throws {
        
    }
}
