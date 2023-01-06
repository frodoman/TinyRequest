import XCTest
import Combine
@testable import TinyRequest

final class TinyRequestTests: XCTestCase {
    
    var cancllables: [AnyCancellable] = []
    
    private func getMockURL() throws -> URL {
        try MockData.urlForFile(name: "people", type: "json")
    }
    
    func testObjectPublisher() throws {
        
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
    
    func testDataPublisher() throws {
        let url = try getMockURL()
        let exp = expectation(description: "Expecting [Person] object")
        
        let expectedData = try Data(contentsOf: url)
        
        TinyRequest(url: url)
            .dataPublisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { data in
                XCTAssertEqual(data, expectedData)
                exp.fulfill()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testResponsePublisher() throws {
        let url = try getMockURL()
        let exp = expectation(description: "Expecting [Person] object")
          
        TinyRequest(url: url)
            .responsePublisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { response in
                XCTAssertEqual(response.url, url)
                exp.fulfill()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
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
        let bodyData = ["body": "body-value"].toData()
        let mockRequest = MockURLRequest()
        let tinyRequest = TinyRequest(request: mockRequest,
                                      session: .shared,
                                      decoder: JSONDecoder())
        
        _ = tinyRequest.set(body: bodyData!)
        
        XCTAssertEqual(mockRequest.httpBody, bodyData)
    }
    
    func testSetBodyObject() throws {
        let person = Person(firstName: "FirstName", lastName: "LastName")
        let bodyData = person.toData()
        
        let mockRequest = MockURLRequest()
        let tinyRequest = TinyRequest(request: mockRequest,
                                      session: .shared,
                                      decoder: JSONDecoder())
        
        _ = tinyRequest.setBody(object: person)
        
        XCTAssertEqual(mockRequest.httpBody, bodyData)
    }
}
