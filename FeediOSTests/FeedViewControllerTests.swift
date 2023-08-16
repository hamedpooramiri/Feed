//
//  FeedViewControllerTests.swift
//  FeediOSTests
//
//  Created by hamedpouramiri on 8/16/23.
//

import XCTest
import Feed
import UIKit

class FeedViewController: UIViewController {

    var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doseNotLoadFeed() {
        let (loader, _) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_LoadsFeed() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    
    //MARK:  Helper
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (loader, sut)
    }

    class LoaderSpy: FeedLoader {

        private(set ) var loadCallCount: Int = 0

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
