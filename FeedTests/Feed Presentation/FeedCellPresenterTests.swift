//
//  FeedCellPresenterTests.swift
//  FeedTests
//
//  Created by hamedpouramiri on 8/22/23.
//

import XCTest
import Feed

final class FeedCellPresenterTests: XCTestCase {

    func test_init_doseNotSendMessagesToView(){
        let (view, _) = makeSUT()
        XCTAssertEqual(view.messages, [])
    }

    func test_didStartLoadingImage_displayCellIsLoading() {
        let (view, sut) = makeSUT()
        let item = FeedItem(id: UUID(),
                            description: "a description",
                            location: "a location",
                            imageUrl: URL(string: "https://a-url.com")!)
        sut.didStartLoadingImage(for: item)
        XCTAssertEqual(view.messages, [.display(isLoading: true, canRety: false)])
    }
   
    func test_didFinishedLoadingImageWithError_displayCellCanRetry() {
        let (view, sut) = makeSUT()
        let item = FeedItem(id: UUID(),
                            description: "a description",
                            location: "a location",
                            imageUrl: URL(string: "https://a-url.com")!)
        let error = NSError(domain: "an error", code: 0)
        sut.didFinishedLoadingImage(for: item, with: error)
        XCTAssertEqual(view.messages, [.display(isLoading: false, canRety: true)])
    }

    func test_didFinishedLoadingImageWithData_onSuccessTransformer_displayCellWithImage() {
        let (view, sut) = makeSUT { data in
            return "an Image" // success conversion
        }
        let item = FeedItem(id: UUID(),
                            description: "a description",
                            location: "a location",
                            imageUrl: URL(string: "https://a-url.com")!)
        sut.didFinishedLoadingImage(for: item, with: Data())
        XCTAssertEqual(view.messages, [.display(isLoading: false, canRety: false, imageData: "an Image")])
    }

    func test_didFinishedLoadingImageWithData_onFailTransformer_displayCellWithNoImage() {
        let (view, sut) = makeSUT { data in
            return nil // fail Conversion
        }
        let item = FeedItem(id: UUID(),
                            description: "a description",
                            location: "a location",
                            imageUrl: URL(string: "https://a-url.com")!)
        sut.didFinishedLoadingImage(for: item, with: Data())
        XCTAssertEqual(view.messages, [.display(isLoading: false, canRety: true, imageData: nil)])
    }

    // MARK: Helpers
    func makeSUT(imageTransformer:  @escaping (Data) -> String? = { _ in return nil }, file: StaticString = #filePath, line: UInt = #line) -> (view: ViewSpy, sut: FeedCellPresenter<ViewSpy, String>){
        let view = ViewSpy()
        let sut = FeedCellPresenter(feedCellView: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (view, sut)
    }

    class ViewSpy: FeedCellView {
        
        enum Messages: Hashable {
            case display(isLoading: Bool, canRety: Bool, imageData: String? = nil)
        }
        
        var messages = Set<Messages>()

        func display(_ viewModel: FeedCellViewModel<String>) {
            messages.insert(.display(isLoading: viewModel.isLoading, canRety: viewModel.canRety, imageData: viewModel.image))
        }
    }
}
