import XCTest
import Combine
@testable import TinyRequest

final class TinyRequestTests: XCTestCase {
    
    var cancllables: [AnyCancellable] = []
    
    func testExample() throws {
        //let bundle = Bundle(for: TinyRequestTests.self)
              
        guard let url = Bundle.module.url(forResource: "people", withExtension: "json") else {
            throw TestError.fileNotFound("people.json")
        }
        
        let exp = expectation(description: "Expecting [Person] object")
        
        TinyRequest(url: url)
            .set(method: "GET")
            .objectPublisher(returnType: [Person].self)
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
}
