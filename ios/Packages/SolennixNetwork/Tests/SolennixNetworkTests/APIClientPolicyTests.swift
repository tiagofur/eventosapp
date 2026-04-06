import XCTest
@testable import SolennixNetwork

final class APIClientPolicyTests: XCTestCase {

    func testShouldQueueMutationAllowsCrudMutations() {
        XCTAssertTrue(APIClient.shouldQueueMutation(endpoint: "/events", method: "POST"))
        XCTAssertTrue(APIClient.shouldQueueMutation(endpoint: "/events/123", method: "PUT"))
        XCTAssertTrue(APIClient.shouldQueueMutation(endpoint: "/events/123", method: "DELETE"))
    }

    func testShouldQueueMutationSkipsAuthAndUploads() {
        XCTAssertFalse(APIClient.shouldQueueMutation(endpoint: "/auth/login", method: "POST"))
        XCTAssertFalse(APIClient.shouldQueueMutation(endpoint: "/uploads/image", method: "POST"))
    }

    func testShouldQueueMutationSkipsReadOperations() {
        XCTAssertFalse(APIClient.shouldQueueMutation(endpoint: "/events", method: "GET"))
        XCTAssertFalse(APIClient.shouldQueueMutation(endpoint: "/events/123", method: "PATCH"))
    }

    func testShouldDropReplayForPermanentClientErrors() {
        XCTAssertTrue(APIClient.shouldDropReplay(statusCode: 400))
        XCTAssertTrue(APIClient.shouldDropReplay(statusCode: 404))
        XCTAssertTrue(APIClient.shouldDropReplay(statusCode: 422))
    }

    func testShouldKeepReplayFor429AndServerErrors() {
        XCTAssertFalse(APIClient.shouldDropReplay(statusCode: 429))
        XCTAssertFalse(APIClient.shouldDropReplay(statusCode: 500))
        XCTAssertFalse(APIClient.shouldDropReplay(statusCode: 503))
    }
}
