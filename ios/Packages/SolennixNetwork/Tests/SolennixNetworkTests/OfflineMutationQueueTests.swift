import Foundation
import XCTest
@testable import SolennixNetwork

final class OfflineMutationQueueTests: XCTestCase {

    func testEnqueueAndDequeueAllPreservesOrder() async {
        let defaults = makeIsolatedDefaults()
        let queue = OfflineMutationQueue(userDefaults: defaults)

        let first = QueuedMutation(
            id: "m1",
            endpoint: "/events",
            method: "POST",
            bodyBase64: nil,
            idempotencyKey: "k1",
            createdAt: Date()
        )
        let second = QueuedMutation(
            id: "m2",
            endpoint: "/events/123",
            method: "PUT",
            bodyBase64: Data("{}".utf8).base64EncodedString(),
            idempotencyKey: "k2",
            createdAt: Date().addingTimeInterval(1)
        )

        await queue.enqueue(first)
        await queue.enqueue(second)

        let dequeued = await queue.dequeueAll()
        XCTAssertEqual(dequeued.map(\.id), ["m1", "m2"])
        let after = await queue.dequeueAll()
        XCTAssertTrue(after.isEmpty)
    }

    func testReplaceOverwritesCurrentQueue() async {
        let defaults = makeIsolatedDefaults()
        let queue = OfflineMutationQueue(userDefaults: defaults)

        await queue.enqueue(
            QueuedMutation(
                id: "old",
                endpoint: "/events",
                method: "POST",
                bodyBase64: nil,
                idempotencyKey: "old-key",
                createdAt: Date()
            )
        )

        await queue.replace(with: [
            QueuedMutation(
                id: "new",
                endpoint: "/events/1",
                method: "DELETE",
                bodyBase64: nil,
                idempotencyKey: "new-key",
                createdAt: Date()
            )
        ])

        let dequeued = await queue.dequeueAll()
        XCTAssertEqual(dequeued.map(\.id), ["new"])
    }

    private func makeIsolatedDefaults() -> UserDefaults {
        let suiteName = "OfflineMutationQueueTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
