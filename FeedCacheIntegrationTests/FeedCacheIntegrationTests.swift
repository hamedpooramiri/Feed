//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by hamedpouramiri on 8/14/23.
//

import XCTest
import Feed

final class FeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        setUpEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_load_emptyCache_deliversNoItems() {
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }

    func test_load_nonEmptyCache_seprateInstanceDeliversItems() {
        let insertSut = makeSUT()
        let expectedItems = uniqueFeeds().models
        save(items: expectedItems, with: insertSut)

        let loadSut = makeSUT()
        expect(loadSut, toLoad: expectedItems)
    }

    func test_save_overridesItemsSavedBySeprateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstItems = uniqueFeeds().models
        let lastItems = uniqueFeeds().models
        
        save(items: firstItems, with: sutToPerformFirstSave)
        save(items: lastItems, with: sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: lastItems)
    }

    //MARK: Helpers
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = storeURLForTest()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func expect(_ sut: LocalFeedLoader, toLoad expectedItems: [FeedItem], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load from cache")
        sut.load { result in
            switch result {
            case let .success(recievedItems):
                XCTAssertEqual(recievedItems, expectedItems, "expected to get \(expectedItems), but got \(recievedItems)", file: file, line: line)
            case let .failure(error):
                XCTAssertNil(error, "expected to get success result, but got error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    func save(items: [FeedItem], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load from cache")
        sut.save(items: items) { result  in
            switch result {
            case .failure(let error):
                XCTAssertNil(error, "expect to save Data Successfully but got error: \(String(describing: error))", file: file, line: line)
            default:
                break
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    private func storeURLForTest() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(type(of: self)).store")
    }

    private func setUpEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: storeURLForTest())
    }
}
