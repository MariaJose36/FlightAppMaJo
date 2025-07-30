//
//  CodeChallengeFlightAppTests.swift
//  CodeChallengeFlightAppTests
//
//  Created by Cincinnati Ai on 7/30/25.
//
import Combine
import XCTest
@testable import CodeChallengeFlightApp

final class FlightViewModelTests: XCTestCase {
    private var viewModel: FlightViewModel!
    private var mockFlightService: MockFlightService!
    private var subscriptions = Set<AnyCancellable>()
    private var mockFlightResponse = FlightResponse(data: [
        DataFlight(
            flightDate: "2025-07-31",
            flightStatus: "scheduled",
            departure: DepartureData(
                airport: nil,
                timezone: nil,
                iata: "PEK",
                icao: "ZBAA",
                terminal: nil,
                gate: nil),
            arrival: ArrivalData(
                airport: nil,
                timezone: nil,
                iata: "SHA",
                icao: "ZSSS",
                terminal: nil,
                gate: nil),
            airline: AirlineData(
                name: "China Eastern Airlines",
                iata: "MU",
                icao: "CES"),
            flight: FlightData(
                number: "5104",
                iata: "MU5104",
                icao: "CES5104",
                codeshared: nil)
        )], pagination: Pagination(
            limit: 20,
            offset: 0,
            count: 20,
            total: 235391)
    )
    
    override func setUp() {
        super.setUp()
        mockFlightService = MockFlightService()
        viewModel = FlightViewModel(service: mockFlightService)
    }
    override func tearDown() {
        viewModel = nil
        mockFlightService = nil
        subscriptions.removeAll()
        super.tearDown()
    }
    
    func testFetchFlightInfo_Success() {
        // Given
        mockFlightService.result = .success(mockFlightResponse)
        let expectation = XCTestExpectation(description: "Fetch success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let info) = state {
                    XCTAssertEqual(info.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        // When
        viewModel.fetchFlightInfo()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchInfo_Failure() {
        // Given
        mockFlightService.result = .failure(FlightServiceError.mockError)
        let expectation = XCTestExpectation(description: "Fetch failure")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, "Failed fetching data")
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        // When
        viewModel.fetchFlightInfo()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateSearchQuery_QueryChanges() {
        // Given
        mockFlightService.result = .success(mockFlightResponse)
        let expectation = XCTestExpectation(description: "Query updated")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let info) = state {
                    XCTAssertEqual(info.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        // When
        viewModel.updateSearchQuery("pek")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateSearchQuery_EmptyQuery() {
        // Given
        mockFlightService.result = .success(mockFlightResponse)
        viewModel.updateSearchQuery("abc")

        let expectation = XCTestExpectation(description: "Cleared query")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let info) = state {
                    XCTAssertEqual(info.count, 1)
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)
        
        // When
        viewModel.updateSearchQuery(" ")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
