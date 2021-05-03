//
//  GitHubReposAppTests.swift
//  GitHubReposAppTests
//
//  Created by 前澤健一 on 2021/02/17.
//

import XCTest
import RxBlocking
import RxTest
import RxSwift
@testable import GitHubReposApp


class GitHubReposAppTests: XCTestCase {
    
    var dataStore: DataStoreProtocol!
    let disposeBag = DisposeBag()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let userDefaultMock: UserDefaultsProtocol = UserDefaultsMock()
        self.dataStore = UserDefaultsDataStore(userDefaults: userDefaultMock)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let result = try dataStore.fetch(ids: [1, 2, 3, 4]).toBlocking().first()
            
        XCTAssertEqual(try result, [1: true, 2: false, 3: true])
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
