//
//  FlightCoorindator.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//

import Foundation
import UIKit

protocol DetailsNavigationDelegate: AnyObject {
    func didSelectFlight(with flightNumber: String)
}
final class FlightCoorindator {
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewController = FlightViewController()
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: false)
    }
}

extension FlightCoorindator: DetailsNavigationDelegate {
    func didSelectFlight(with flightNumber: String) {
        let viewModel = FlightDetailsViewModel(flightNumber: flightNumber)
        let viewController = FlightDetailsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
