//
//  FeedViewControllerTests.swift
//  FeediOSTests
//
//  Created by hamedpouramiri on 8/16/23.
//

import XCTest
import Feed
import UIKit

class FeedViewController: UITableViewController {

    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0, "expect to not loadFeeds before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "expect to loadFeeds after view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "expect to loadFeeds when user initiate a Reload request")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "expect to loadFeeds when user initiate a Reload request again")
    }
    
    func test_loadingIndicator_showWhenLoadingFeed() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect to show loadingIndicator when loadinFeeds after view is loaded")
        loader.completeLoadingSuccessfully()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect to hide loadingIndicator after getting new Feeds")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect to show loadingIndicator when user request to reload Feeds")
        loader.completeLoadingSuccessfully(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect to hide loadingIndicator after getting new Feeds")
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

        private(set) var capturedLoadCompletions: [(FeedLoader.Result) -> Void] = []
        
        var loadCallCount: Int {
            capturedLoadCompletions.count
        }
        
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            capturedLoadCompletions.append(completion)
        }

        func completeLoadingSuccessfully(at index: Int = 0) {
            capturedLoadCompletions[index](.success([]))
        }
    }
}

// MARK: DSL functions
// for hiding implementation details from the Tests
private extension FeedViewController {
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                (target as NSObject).perform(Selector(action))
            })
        }
    }
}
