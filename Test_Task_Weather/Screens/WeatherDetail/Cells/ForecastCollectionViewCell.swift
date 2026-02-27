//
//  ForecastCollectionViewCell.swift
//  Test_Task_Weather
//
//  Created by developer on 1.03.26.
//

import UIKit

final class ForecastCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ForecastCell"

    private let dateLabel = UILabel()
    private let tempLabel = UILabel()
    private let pressureLabel = UILabel()
    private let humidityLabel = UILabel()
    private let visibilityLabel = UILabel()
    private let cloudsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: ForecastItem) {
        dateLabel.text = item.date.formatted(.dateTime.hour(.twoDigits(amPM: .wide)).minute(.twoDigits))
        tempLabel.text = "Temperature: \(item.temperatureCelsius) C"
        pressureLabel.text = "Pressure: \(item.pressureHPa) hPa"
        humidityLabel.text = "Humidity: \(item.humidityPercent)%"
        visibilityLabel.text = "Visibility: \(item.visibility) m"
        cloudsLabel.text = "Cloudiness: \(item.cloudsPercent)%"
    }

    private func setupUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12

        [dateLabel, tempLabel, humidityLabel, pressureLabel, visibilityLabel, cloudsLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        dateLabel.font = .preferredFont(forTextStyle: .headline)
        tempLabel.font = .preferredFont(forTextStyle: .headline)
        humidityLabel.font = .preferredFont(forTextStyle: .body)
        pressureLabel.font = .preferredFont(forTextStyle: .body)
        visibilityLabel.font = .preferredFont(forTextStyle: .body)
        cloudsLabel.font = .preferredFont(forTextStyle: .body)

        let stack = UIStackView(arrangedSubviews: [dateLabel, tempLabel, pressureLabel, humidityLabel, visibilityLabel, cloudsLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "Header"
    
    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 18)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
