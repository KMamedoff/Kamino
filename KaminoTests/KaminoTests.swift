//
//  KaminoTests.swift
//  KaminoTests
//
//  Created by Kenan Mamedoff on 02/04/2019.
//  Copyright © 2019 Kenan Mamedoff. All rights reserved.
//

import XCTest
@testable import Kamino

class KaminoTests: XCTestCase {
    
    func testGETService() {
        let exp = expectation(description: "GET Request")
        
        let planetUrlString = "https://private-bef1e9-starwars2.apiary-mock.com/planets/10"
        Service.shared.getRequest(urlString: planetUrlString) { (feed: Planet) in
            XCTAssertNotNil(feed)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPOSTService() {
        let exp = expectation(description: "POST Request")
        
        let likeUrlString = "https://private-bef1e9-starwars2.apiary-mock.com/planets/10/like"
        Service.shared.postRequest(urlString: likeUrlString, body: "{\n  \"planet_id\": 10\n}", value: [["application/json", "Content-Type"]]) { (feed: PostLikes) in
            
            XCTAssertEqual(feed.planetId, 10)
            XCTAssertEqual(feed.likes, 10)
            XCTAssertNotNil(feed)
            exp.fulfill()
            
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
