//
//  NetworkReachabilityManagerTests.swift
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@testable import Alamofire
import Foundation
import SystemConfiguration
import XCTest

final class NetworkReachabilityManagerTestCase: BaseTestCase {

    // MARK: - Tests - Initialization

    func testThatManagerCanBeInitializedFromHost() {
        // Given, When
        let manager = NetworkReachabilityManager(host: "localhost")

        // Then
        XCTAssertNotNil(manager)
    }

    func testThatManagerCanBeInitializedFromAddress() {
        // Given, When
        let manager = NetworkReachabilityManager()

        // Then
        XCTAssertNotNil(manager)
    }

    func testThatHostManagerIsReachableOnWiFi() {
        // Given, When
        let manager = NetworkReachabilityManager(host: "localhost")

        // Then
        XCTAssertEqual(manager?.status, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnCellular, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func testThatHostManagerStartsWithReachableStatus() {
        // Given, When
        let manager = NetworkReachabilityManager(host: "localhost")

        // Then
        XCTAssertEqual(manager?.status, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnCellular, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func testThatAddressManagerStartsWithReachableStatus() {
        // Given, When
        let manager = NetworkReachabilityManager()

        // Then
        XCTAssertEqual(manager?.status, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnCellular, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func testThatZeroManagerCanBeProperlyRestarted() {
        // Given
        let manager = NetworkReachabilityManager()
        let first = expectation(description: "first listener notified")
        let second = expectation(description: "second listener notified")

        // When
        manager?.startListening { (status) in
            first.fulfill()
        }
        wait(for: [first], timeout: timeout)

        manager?.stopListening()

        manager?.startListening { (status) in
            second.fulfill()
        }
        wait(for: [second], timeout: timeout)

        // Then
        XCTAssertEqual(manager?.status, .reachable(.ethernetOrWiFi))
    }

    func testThatHostManagerCanBeProperlyRestarted() {
        // Given
        let manager = NetworkReachabilityManager(host: "localhost")
        let first = expectation(description: "first listener notified")
        let second = expectation(description: "second listener notified")

        // When
        manager?.startListening { (status) in
            first.fulfill()
        }
        wait(for: [first], timeout: timeout)

        manager?.stopListening()

        manager?.startListening { (status) in
            second.fulfill()
        }
        wait(for: [second], timeout: timeout)

        // Then
        XCTAssertEqual(manager?.status, .reachable(.ethernetOrWiFi))
    }

    func testThatHostManagerCanBeDeinitialized() {
        // Given
        var manager: NetworkReachabilityManager? = NetworkReachabilityManager(host: "localhost")

        // When
        manager = nil

        // Then
        XCTAssertNil(manager)
    }

    func testThatAddressManagerCanBeDeinitialized() {
        // Given
        var manager: NetworkReachabilityManager? = NetworkReachabilityManager()

        // When
        manager = nil

        // Then
        XCTAssertNil(manager)
    }

    // MARK: - Listener

    func testThatHostManagerIsNotifiedWhenStartListeningIsCalled() {
        // Given
        guard let manager = NetworkReachabilityManager(host: "store.apple.com") else {
            XCTFail("manager should NOT be nil")
            return
        }

        let expectation = self.expectation(description: "listener closure should be executed")
        var networkReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus?

        // When
        manager.startListening { status in
            guard networkReachabilityStatus == nil else { return }
            networkReachabilityStatus = status
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    func testThatAddressManagerIsNotifiedWhenStartListeningIsCalled() {
        // Given
        let manager = NetworkReachabilityManager()
        let expectation = self.expectation(description: "listener closure should be executed")

        var networkReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus?

        // When
        manager?.startListening { status in
            networkReachabilityStatus = status
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    // MARK: - NetworkReachabilityStatus

    func testThatStatusIsNotReachableStatusWhenReachableFlagIsAbsent() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.connectionOnDemand]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .notReachable)
    }

    func testThatStatusIsNotReachableStatusWhenConnectionIsRequired() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .notReachable)
    }

    func testThatStatusIsNotReachableStatusWhenInterventionIsRequired() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .interventionRequired]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .notReachable)
    }

    func testThatStatusIsReachableOnWiFiStatusWhenConnectionIsNotRequired() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .reachable(.ethernetOrWiFi))
    }

    func testThatStatusIsReachableOnWiFiStatusWhenConnectionIsOnDemand() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnDemand]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .reachable(.ethernetOrWiFi))
    }

    func testThatStatusIsReachableOnWiFiStatusWhenConnectionIsOnTraffic() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnTraffic]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .reachable(.ethernetOrWiFi))
    }

#if os(iOS) || os(tvOS)
    func testThatStatusIsReachableOnCellularStatusWhenIsWWAN() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .isWWAN]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .reachable(.cellular))
    }

    func testThatStatusIsNotReachableOnCellularStatusWhenIsWWANAndConnectionIsRequired() {
        // Given
        let flags: SCNetworkReachabilityFlags = [.reachable, .isWWAN, .connectionRequired]

        // When
        let status = NetworkReachabilityManager.NetworkReachabilityStatus(flags)

        // Then
        XCTAssertEqual(status, .notReachable)
    }
#endif
}
