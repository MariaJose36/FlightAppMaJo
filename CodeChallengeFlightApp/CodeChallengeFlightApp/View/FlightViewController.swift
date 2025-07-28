//
//  FlightViewController.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//
import Combine
import UIKit

final class FlightViewController: UIViewController {
    private let viewModel = FlightViewModel()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Flight App"
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .purple
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let tableView = UITableView(frame: .zero)
    private var displayableInfo: [DisplayableFlightInfo] = []
    private var subscriptions = Set<AnyCancellable>()
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    weak var delegate: DetailsNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        listenToViewModel()
        viewModel.fetchFlightInfo()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FlightTableViewCell.self, forCellReuseIdentifier: FlightTableViewCell.reuseIdentifier)
        let headerView = createHeaderView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        tableView.tableHeaderView = headerView
    }
    
    private func listenToViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(with: state)
            }
            .store(in: &subscriptions)
    }
    
    private func handleState(with state: FlightState) {
        switch state {
        case .none:
            break
        case .loading:
            activityIndicator.startAnimating()
        case .success(let displayableInfo):
            activityIndicator.stopAnimating()
            self.displayableInfo = displayableInfo
            tableView.reloadData()
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

    private func createHeaderView() -> UIView {
        let header = UIStackView()
        header.axis = .horizontal
        header.distribution = .fillEqually
        header.alignment = .center
        header.spacing = 10
        header.translatesAutoresizingMaskIntoConstraints = false
        
        let titles = ["Flight Number", "Origin", "Destination"]
        titles.forEach { title in
            let label = UILabel()
            label.text = title
            label.font = UIFont.preferredFont(forTextStyle: .headline)
            header.addArrangedSubview(label)
        }
        
        let container = UIView()
        container.addSubview(header)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            header.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            header.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            header.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
        ])
        
        return container
    }
}

extension FlightViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayableInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FlightTableViewCell.reuseIdentifier,
            for: indexPath) as? FlightTableViewCell else {
            return UITableViewCell()
        }
        let info = displayableInfo[indexPath.row]
        cell.configure(with: info)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = displayableInfo[indexPath.row]
        delegate?.didSelectFlight(with: info.flightNumber)
    }
}

