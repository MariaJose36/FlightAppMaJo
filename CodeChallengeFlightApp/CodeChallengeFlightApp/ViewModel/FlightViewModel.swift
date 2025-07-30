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
    private var offset = 0
    private let limit = 20
    private var total = Int.max
    private var isLoading = false
    private var displayableFlightInfo: [DisplayableFlightInfo] = []
    private var searchQuery: String = ""

    init(service: FlightServiceContract = FlightService()) {
        self.service = service
    }
    
    func fetchFlightInfo() {
        guard !isLoading, offset < total else { return }
        isLoading = true
        if offset == 0 {
            state = .loading
        }
        service.fetchFlightInfo(offset: offset, limit: limit, searchQuery: searchQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished: break
                case .failure: self?.state = .error("Failed fetching data")
                }
            } receiveValue: { [weak self] displayableInfo in
                self?.isLoading = false
                self?.onInfoFetch(with: displayableInfo)
            }
            .store(in: &subscriptions)
    }
    
    private func onInfoFetch(with response: FlightResponse) {
        total = response.pagination?.total ?? Int.max
        offset += response.pagination?.count ?? 0
        let newInfo = mapToDisplayableInfo(with: response.data)
        self.displayableFlightInfo.append(contentsOf: newInfo)
        state = .success(self.displayableFlightInfo)
    }

    private func mapToDisplayableInfo(with data: [DataFlight]?) -> [DisplayableFlightInfo] {
        guard let data else { return [] }
        return data.map { flightData in
            let flightNumber = flightData.flight?.iata ?? ""
            let departure = flightData.departure?.iata ?? ""
            let arrival = flightData.arrival?.iata ?? ""
            return DisplayableFlightInfo(flightNumber: flightNumber,
                                  departure: departure,
                                  arrival: arrival
            )
        }
    }
    
    func updateSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if searchQuery != trimmed {
            searchQuery = trimmed
            resetAndFetch()
        } else if trimmed.isEmpty && !searchQuery.isEmpty {
            searchQuery = ""
            resetAndFetch()
        }
    }
    
    private func resetAndFetch() {
        offset = 0
        total = Int.max
        displayableFlightInfo.removeAll()
        fetchFlightInfo()
    }
}

enum FlightState {
    case none
    case loading
    case success([DisplayableFlightInfo])
    case error(String)
}
