//
//  FlightViewModel.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//
import Combine
import Foundation

final class FlightViewModel {
    private let service: FlightServiceContract
    @Published var state: FlightState = .none
    private var subscriptions = Set<AnyCancellable>()

    init(service: FlightServiceContract = FlightService()) {
        self.service = service
    }
    
    func fetchFlightInfo() {
        state = .loading
        service.fetchFlightInfo()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure: self?.state = .error("Failed fetching data")
                }
            } receiveValue: { [weak self] displayableInfo in
                self?.onInfoFetch(with: displayableInfo)
            }
            .store(in: &subscriptions)
    }
    
    private func onInfoFetch(with response: FlightResponse) {
        let displayableInfo = mapToDisplayableInfo(with: response.data)
        state = .success(displayableInfo)
    }

    private func mapToDisplayableInfo(with data: [DataFlight]?) -> [DisplayableFlightInfo] {
        guard let data else { return [] }
        return data.map { flightData in
            DisplayableFlightInfo(flightNumber: flightData.flight?.iata ?? "",
                                  departure: flightData.departure?.iata ?? "",
                                  arrival: flightData.arrival?.iata ?? ""
            )
        }
    }
}

enum FlightState {
    case none
    case loading
    case success([DisplayableFlightInfo])
    case error(String)
}
