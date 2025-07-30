//
//  FlightTableViewCell.swift
//  CodeChallengeFlightApp
//
//  Created by Cincinnati Ai on 7/28/25.
//

import UIKit

final class FlightTableViewCell: UITableViewCell {
    static let reuseIdentifier = "FlightTableViewCell"
    private var valueLabels: [UILabel] = []
    private let flightNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let departureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrivalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(flightNumberLabel)
        stackView.addArrangedSubview(departureLabel)
        stackView.addArrangedSubview(arrivalLabel)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with info: DisplayableFlightInfo) {
        let columns = columns(from: info)
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for column in columns {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .body)
            label.text = column.value
            stackView.addArrangedSubview(label)
        }
    }
    
    private func columns(from info: DisplayableFlightInfo) -> [FlightColumn] {
        return [
            FlightColumn(key: "Flight number", value: info.flightNumber),
            FlightColumn(key: "Origin", value: info.departure),
            FlightColumn(key: "Dest", value: info.arrival)
        ]
    }
}

struct FlightColumn {
    let key: String
    let value: String
}
