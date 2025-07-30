//
//  FlightDetailsViewModelTests.swift
//  CodeChallengeFlightAppTests
//
//  Created by Cincinnati Ai on 7/30/25.
//
import Combine
import XCTest
@testable import CodeChallengeFlightApp

final class FlightDetailsViewModelTests: XCTestCase {
    private var viewModel: FlightDetailsViewModel!
    private var mockFlightService: MockFlightService!
    private var subscriptions = Set<AnyCancellable>()
    private var mockDataFlight = DataFlight(
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
    )
    
    override func setUp() {
        super.setUp()
        mockFlightService = MockFlightService()
        viewModel = FlightDetailsViewModel(flightNumber: "MU5104", service: mockFlightService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockFlightService = nil
        subscriptions.removeAll()
        super.tearDown()
    }
    
    func testFetchFlightDetails_Success() {
        mockFlightService.dataFlight = .success(mockDataFlight)
        let expectation = XCTestExpectation(description: "Fetch success")

        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let info) = state {
                    XCTAssertEqual(info.flightNumber, "MU5104")
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        // When
        viewModel.fetchDetails()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchFlightDetails_Failure() {
        // Given
        mockFlightService.dataFlight = .failure(FlightServiceError.mockError)
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
        viewModel.fetchDetails()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
