//
//  FeedViewControllerTests.swift
//  FeediOSTests
//
//  Created by hamedpouramiri on 8/16/23.
//

import XCTest
import Feed
import FeediOS
import UIKit

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "expect to not loadFeeds before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "expect to loadFeeds after view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "expect to loadFeeds when user initiate a Reload request")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "expect to loadFeeds when user initiate a Reload request again")
    }
    
    func test_load_showLoadingIndicatorWhenLoadingFeed() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect to show loadingIndicator when loadinFeeds after view is loaded")
        loader.completeLoading()
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect to hide loadingIndicator after getting new Feeds")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect to show loadingIndicator when user request to reload Feeds")
        loader.completeLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect to hide loadingIndicator after getting new Feeds")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect to show loadingIndicator when user request to reload Feeds")
        let error = NSError(domain: "an error", code: 0)
        loader.completeLoadingWithError(error: error,at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "expect to hide loadingIndicator after getting an error")
    }

    func test_loadCompletion_renderItems() {
        let item = makefeedItem(description: "a description", location: "a location")
        let items = [
            makefeedItem(description: "a description", location: "a location"),
            makefeedItem(description: "a description"),
            makefeedItem(location: "a location")
        ]

        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading()
        assertThat(sut, isRendering: [])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoading(with: [item], at: 1)
        assertThat(sut, isRendering: [item])
       
        sut.simulateUserInitiatedFeedReload()
        loader.completeLoading(with: items, at: 2)
        assertThat(sut, isRendering: items)
        
    }

    func test_load_doseNotAlterCurrentRenderingStateOnError() {
        let feed = [makefeedItem()]
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(with: feed)
        assertThat(sut, isRendering: feed)

        sut.simulateUserInitiatedFeedReload()
        let error = NSError(domain: "an error", code: 0)
        loader.completeLoadingWithError(error: error, at: 1)
        assertThat(sut, isRendering: feed)
    }
    
    func test_feedItemCell_loadsImageURLWhenVisible() {
        let item1 = makefeedItem(imageUrl: URL(string: "https://url-0.com")!)
        let item2 = makefeedItem(imageUrl: URL(string: "https://url-1.com")!)
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [item1, item2])
        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulatefeedItemCellIsVisible()
        XCTAssertEqual(loader.loadedImageURLs, [item1.imageUrl])
        
        sut.simulatefeedItemCellIsVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [item1.imageUrl, item2.imageUrl])
    }

    func test_feedItemCell_cancelLoadingImageURLWhenNotVisible() {
        let item1 = makefeedItem(imageUrl: URL(string: "https://url-0.com")!)
        let item2 = makefeedItem(imageUrl: URL(string: "https://url-1.com")!)
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLoading(with: [item1, item2])
        XCTAssertEqual(loader.canceledImageURLs, [])
        
        sut.simulatefeedItemCellIsNotVisible()
        XCTAssertEqual(loader.canceledImageURLs, [item1.imageUrl])
        
        sut.simulatefeedItemCellIsNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [item1.imageUrl, item2.imageUrl])
    }

    //MARK:  Helper
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (loader, sut)
    }

    func assertThat(_ sut: FeedViewController, isRendering items: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeed, items.count, "expect 'numberOfRenderedFeed' to be \(items.count)", file: file, line: line)
        items.enumerated().forEach { index,item in
            assertThat(sut, hasViewConfiguredFor: item, at: index, file: file, line: line)
        }
    }

    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor item: FeedItem, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line){
        let view = sut.feedItemCell(at: index)
        guard let cellView = view as? FeedItemCell else {
            return XCTFail("expect \(FeedItemCell.self) instance, but got \(String(describing: view)) instade", file: file, line: line)
        }
        let shouldLocationBeVisible = (item.location != nil)
        XCTAssertEqual(cellView.isShowingLocation, shouldLocationBeVisible, "expect 'isShowingLocation' to be \(shouldLocationBeVisible) for item at index: \(index)", file: file, line: line)
        XCTAssertEqual(cellView.descriptionText, item.description, "expect description to be \(String(describing: item.description)) for item at index: \(index)", file: file, line: line)
        XCTAssertEqual(cellView.locationText, item.location, "expect location to be \(String(describing: item.location)) for item at index: \(index)", file: file, line: line)
        
    }

    func makefeedItem(description: String? = nil, location: String? = nil, imageUrl: URL = URL(string: "http://any-url.com")!) -> FeedItem {
        FeedItem(id: UUID(), description: description, location: location, imageUrl: imageUrl)
    }

    private struct TaskSpy: ImageLoaderTask {
        let cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    class LoaderSpy: FeedLoader, ImageLoader {

        private(set) var capturedLoadCompletions: [(FeedLoader.Result) -> Void] = []

        var loadFeedCallCount: Int {
            capturedLoadCompletions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            capturedLoadCompletions.append(completion)
        }

        func completeLoading(with feed: [FeedItem] = [], at index: Int = 0) {
            capturedLoadCompletions[index](.success(feed))
        }

        func completeLoadingWithError(error: Error, at index: Int = 0) {
            capturedLoadCompletions[index](.failure(error))
        }

        // MARK: imageLoader
        private(set) var loadedImageURLs: [URL] = []
        private(set) var canceledImageURLs: [URL] = []
        
        func loadImage(with url: URL) -> FeediOS.ImageLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in self?.canceledImageURLs.append(url) }
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

    var numberOfRenderedFeed: Int {
        tableView.numberOfRows(inSection: feedSection)
    }

    private var feedSection: Int {
        return 0
    }

    func feedItemCell(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: index, section: feedSection))
    }

    @discardableResult
    func simulatefeedItemCellIsVisible(at index: Int = 0) -> FeedItemCell? {
        let cell = feedItemCell(at: index) as? FeedItemCell
        return cell
    }

    func simulatefeedItemCellIsNotVisible(at index: Int = 0) {
        let cell = simulatefeedItemCellIsVisible(at: index)
        let indexPath = IndexPath(row: index, section: feedSection)
        tableView.delegate?.tableView?(tableView, didEndDisplaying: cell!, forRowAt: indexPath)
    }
}

private extension FeedItemCell {
    var isShowingLocation: Bool {
        !locationContainer .isHidden
    }
    var locationText: String? {
        locationLabel.text
    }
    var descriptionText: String? {
        descriptionLabel.text
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
