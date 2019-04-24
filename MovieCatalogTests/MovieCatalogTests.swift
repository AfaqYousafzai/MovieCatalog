//
//  MovieCatalogTests.swift
//  MovieCatalogTests
//
//  Created by Afaq on 20/04/2019.
//  Copyright © 2019 Afaq. All rights reserved.
//

import XCTest
@testable import MovieCatalog

class MovieCatalogTests: XCTestCase {

    var viewControllerTest: ViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        viewControllerTest = ViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewControllerTest = nil
    }
    
    func testPopularMoviesParseData(){
        
        if let path = Bundle.main.path(forResource: "popularMovies", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>{
                    viewControllerTest.parseData(data: jsonResult)
                    XCTAssertGreaterThan(viewControllerTest.movies.count, 0)
                }
            } catch {
            }
        }
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
