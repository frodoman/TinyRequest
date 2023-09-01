//
//  TestTinyService.swift
//  
//
//  Created by X_coder on 06/01/2023.
//

import XCTest
import Combine

final class TestTinyService: XCTestCase {
    
    var cancllables: [AnyCancellable] = []

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testGetPeople() {
        let exp = expectation(description: "Expecting [Person] object")
        
        PeopleService.getPeople
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
    
    func testGetPerson() {
        let exp = expectation(description: "Expecting a Person object")
        
        PeopleService.getPerson
            .objectPublisher(type: Person.self)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { person in
                XCTAssertNotNil(person.firstName)
                XCTAssertNotNil(person.lastName)
                
                exp.fulfill()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testDataPublisher() throws {
        let exp = expectation(description: "Expecting a Person object")
        let url = try MockData.urlForFile(name: "person", type: "json")
        let expectedData = try Data(contentsOf: url)
        
        PeopleService.getPerson
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
        let exp = expectation(description: "Expecting a Person object")
        let expectedUrl = try MockData.urlForFile(name: "person", type: "json")
        
        PeopleService.getPerson
            .responsePublisher()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                case .finished:
                    break
                }
            } receiveValue: { response in
                XCTAssertEqual(response.url, expectedUrl)
                
                exp.fulfill()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testInvalidService() throws {
        let exp = expectation(description: "Expecting a Person object")

        InvalidService.downloadSomething
            .dataResponsePublisher()
            .sink { completion in
                switch completion {
                case .failure:
                    exp.fulfill()
                    
                case .finished:
                    break
                }
            } receiveValue: { data, response in
                XCTFail()
            }
            .store(in: &cancllables)
        
        wait(for: [exp], timeout: 5)
    }
    
    func testAsyncObjectResponse() async throws {
        let people = try await PeopleService.getPeople.asyncObject(type: [Person].self)
        XCTAssertTrue(people.count > 0)
    }
    
    func testAsyncDataResponse() async throws {
        let (data, response) = try await PeopleService.getPeople.asyncDataResponse()
        
        XCTAssertNotNil(response.url)
        XCTAssertFalse(data.isEmpty)
    }
}
