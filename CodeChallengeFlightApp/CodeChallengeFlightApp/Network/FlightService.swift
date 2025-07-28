//
//  FlightService.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//
import Combine
import Foundation

protocol FlightServiceContract: AnyObject {
    func fetchFlightInfo() -> AnyPublisher<FlightResponse, Error>
    func fetchFlightDetails(with flightNumber: String) -> AnyPublisher<DataFlight, Error>
}

final class FlightService: FlightServiceContract {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func fetchFlightInfo() -> AnyPublisher<FlightResponse, any Error> {
        guard let url = createFlightURL() else {
            return Fail(error: Errors.invalidUrl).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: FlightResponse.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    private func createFlightURL() -> URL? {
        let queryItems = [URLQueryItem(
            name: Constants.accessKey,
            value: Constants.keyValue
        )]
        var urlComponents = URLComponents(string: Constants.url)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }
}

extension FlightService {
    func fetchFlightDetails(with flightNumber: String) -> AnyPublisher<DataFlight, Error> {
        guard let url = createFlightDefatilsURL(with: flightNumber) else {
            return Fail(error: Errors.invalidUrl).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: FlightResponse.self, decoder: decoder)
            .tryMap { response in
                guard let flight = response.data?.first else {
                    throw Errors.invalidData
                }
                return flight
            }
            .eraseToAnyPublisher()
    }
    
    private func createFlightDefatilsURL(with flightNumber: String) -> URL? {
        let queryItems = [URLQueryItem(
            name: Constants.accessKey,
            value: Constants.keyValue
        ), URLQueryItem(
            name: Constants.flightIata,
            value: "\(flightNumber)"
        )]
        var urlComponents = URLComponents(string: Constants.url)
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }
}

enum Constants {
    static let keyValue = "6499abb5f04a63beac11b3302e191739"
    static let accessKey = "access_key"
    static let url = "https://api.aviationstack.com/v1/flights"
    static let flightIata = "flight_iata"
}

enum Errors: Error {
    case invalidUrl
    case failedFetchingData
    case invalidData
}
