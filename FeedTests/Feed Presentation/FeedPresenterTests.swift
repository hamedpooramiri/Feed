//
//  FeedPresenterTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/22/23.
//

import XCTest
import Feed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}
protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedViewModel {
    let feed: [FeedItem]
}

final class FeedPresenter {

    private let refreshView: FeedLoadingView
    private let feedView: FeedView

    init(refreshView: FeedLoadingView, feedView: FeedView) {
        self.refreshView = refreshView
        self.feedView = feedView
    }

    func didStartLoadingFeed() {
        refreshView.display(FeedLoadingViewModel(isLoading: true))
    }

    func didFinishedLoadingFeed(with error: Error)  {
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }

    func didFinishedLoadingFeed(with feed: [FeedItem]) {
        feedView.display(FeedViewModel(feed: feed))
        refreshView.display(FeedLoadingViewModel(isLoading: false))
    }
}


final class FeedPresenterTests: XCTestCase {

 
    func test_init_doseNotSendMessageToView() {
        let (view, _) = makeSUT()
        XCTAssertEqual(view.messages, [])
    }
    
    func test_didStartLoadingFeed_displayStartLoading() {
        let (view, sut) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }
    
    func test_didFinishedLoadingFeedWithError_displayStopLoading() {
        let (view, sut) = makeSUT()
        let nsError = NSError(domain: "an error", code: 0)
        sut.didFinishedLoadingFeed(with: nsError)
        XCTAssertEqual(view.messages, [.display(isLoading: false)])
    }
    
    func test_didFinishedLoadingFeed_displayFeedAndStopLoading() {
        let (view, sut) = makeSUT()
        sut.didFinishedLoadingFeed(with: [])
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(feed: [])
        ])
    }
    
    // MARK: Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (view: ViewSpy, sut: FeedPresenter){
        let view = ViewSpy()
        let sut = FeedPresenter(refreshView: view, feedView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (view, sut)
    }

    class ViewSpy: FeedLoadingView, FeedView {
        
        enum Messages: Hashable {
            case display(isLoading: Bool)
            case display(feed: [FeedItem])
        }
        
        var messages = Set<Messages>()

        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
    }
}
