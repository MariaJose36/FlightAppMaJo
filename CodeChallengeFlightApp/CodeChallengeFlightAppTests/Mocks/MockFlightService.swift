//
//  MockFlightService.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/30/25.
//

import Combine

enum FlightServiceError: Error {
    case mockError
}
final class MockFlightService: FlightServiceContract {
    var result: Result<FlightResponse, Error>!
    var dataFlight: Result<DataFlight, Error>!

    func fetchFlightInfo(offset: Int, limit: Int, searchQuery: String?) -> AnyPublisher<FlightResponse, Error> {
        return result.publisher.eraseToAnyPublisher()
    }
    func fetchFlightDetails(with flightNumber: String) -> AnyPublisher<DataFlight, Error> {
        return dataFlight.publisher.eraseToAnyPublisher()
    }
}
