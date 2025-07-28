//
//  FlightDetailsViewModel.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//
import Combine
import Foundation

final class FlightDetailsViewModel {
    @Published var state: DetailsState = .none
    private var flightNumber: String
    private var service: FlightServiceContract
    private var subscriptions = Set<AnyCancellable>()
    
    init(flightNumber: String, service: FlightServiceContract = FlightService()) {
        self.flightNumber = flightNumber
        self.service = service
    }
    
    
    func fetchDetails() {
        state = .loading
        service.fetchFlightDetails(with: flightNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure: self?.state = .error("Failed fetching data")
                }
            } receiveValue: { [weak self] details in
                self?.onDetailsFetch(details)
            }
            .store(in: &subscriptions)
    }
    
    private func onDetailsFetch(_ data: DataFlight) {
        let details = mapToDetails(data)
        self.state = .success(details)
        
    }
    private func mapToDetails(_ data: DataFlight) -> DisplayableDetailsInfo {
        return DisplayableDetailsInfo(flightNumber: data.flight?.iata ?? "",
                                      departure: data.departure?.iata ?? "",
                                      arrival: data.arrival?.iata ?? "",
                                      date: data.flightDate ?? "",
                                      status: data.flightStatus ?? "")
    }
}

enum DetailsState {
    case none
    case loading
    case success(DisplayableDetailsInfo)
    case error(String)
}
