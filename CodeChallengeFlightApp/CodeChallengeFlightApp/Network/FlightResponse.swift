//
//  FlightResponse.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//

import Foundation

struct FlightResponse: Codable {
    let data: [DataFlight]?
    let pagination: Pagination?
}

struct DataFlight: Codable {
    let flightDate: String?
    let flightStatus: String?
    let departure: DepartureData?
    let arrival: ArrivalData?
    let airline: AirlineData?
    let flight: FlightData?

    enum CodingKeys: String, CodingKey {
        case flightDate = "flight_date"
        case flightStatus = "flight_status"
        case departure
        case arrival
        case airline
        case flight
    }
}

struct Pagination: Codable {
    let limit: Int?
    let offset: Int?
    let count: Int?
    let total: Int?
}

struct DepartureData: Codable {
    let airport: String?
    let timezone: String?
    let iata: String?
    let icao: String?
    let terminal: String?
    let gate: String?
}

struct ArrivalData: Codable {
    let airport: String?
    let timezone: String?
    let iata: String?
    let icao: String?
    let terminal: String?
    let gate: String?
}

struct AirlineData: Codable {
    let name: String?
    let iata: String?
    let icao: String?
}

struct FlightData: Codable {
    let number: String?
    let iata: String?
    let icao: String?
    let codeshared: CodeSharedData?
}

struct CodeSharedData: Codable {
    let airline_name: String?
    let airline_iata: String?
    let airline_icao: String?
    let flight_number: String?
    let flight_iata: String?
    let flight_icao: String?
}

struct DisplayableFlightInfo {
    let flightNumber: String
    let departure: String
    let arrival: String
}

struct DisplayableDetailsInfo {
    let flightNumber: String
    let departure: String
    let arrival: String
    let date: String
    let status: String
}
