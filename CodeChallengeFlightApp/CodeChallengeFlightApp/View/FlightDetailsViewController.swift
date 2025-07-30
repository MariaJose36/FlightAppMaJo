//
//  FlightDetailsViewController.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//
import Combine
import UIKit

final class FlightDetailsViewController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Details"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .purple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let viewModel: FlightDetailsViewModel
    private let flightNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let originLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let destLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let favoriteSwitch: UISwitch = {
       let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let favoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoriteStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(viewModel: FlightDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        listenToViewModel()
        viewModel.fetchDetails()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        stackView.addArrangedSubview(flightNumberLabel)
        stackView.addArrangedSubview(originLabel)
        stackView.addArrangedSubview(destLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(statusLabel)
        favoriteStack.addArrangedSubview(favoriteSwitch)
        favoriteStack.addArrangedSubview(favoriteLabel)
        stackView.addArrangedSubview(favoriteStack)
        
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        favoriteSwitch.addTarget(self, action: #selector(favoriteToggled), for: .valueChanged)
    }
    
    private func listenToViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &subscriptions)
    }
    
    private func handleState(_ state: DetailsState) {
        switch state {
        case .none:
            break
        case .loading:
            activityIndicator.startAnimating()
        case .success(let displayableDetailsInfo):
            activityIndicator.stopAnimating()
            flightNumberLabel.text = "Flight number \(displayableDetailsInfo.flightNumber)"
            originLabel.text = "Origin: \(displayableDetailsInfo.departure)"
            destLabel.text = "Destination: \(displayableDetailsInfo.arrival)"
            dateLabel.text = "Flight date: \(displayableDetailsInfo.date)"
            statusLabel.text = "Status: \(displayableDetailsInfo.status)"
            let isFavorite = CoreDataManager.shared.isFavorite(flightNumber: displayableDetailsInfo.flightNumber)
            favoriteSwitch.isOn = isFavorite
        case .error(let message):
            activityIndicator.stopAnimating()
            showErrorAlert(message)
        }
    }
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error",
                                       message: message,
                                       preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func favoriteToggled() {
        guard case let .success(details) = viewModel.state else { return }
        let flightNumber = details.flightNumber
        
        if favoriteSwitch.isOn {
            CoreDataManager.shared.saveFavoriteFlight(flightNumber: flightNumber)
        } else {
            CoreDataManager.shared.deleteFavorite(flightNumber: flightNumber)
        }
    }
}
