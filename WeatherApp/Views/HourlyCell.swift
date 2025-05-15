//
//  HourlyCell.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 15.05.2025.
//

import Foundation
import UIKit

class HourlyCell: UICollectionViewCell {
    static let identifier = "HourlyCell"

    let timeLabel = UILabel()
    let iconImageView = UIImageView()
    let tempLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white

        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .center
        tempLabel.textColor = .white

        iconImageView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [timeLabel, iconImageView, tempLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with hour: Hour) {
        let dateStr = hour.time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: dateStr) {
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: date)
        } else {
            timeLabel.text = "--"
        }

        tempLabel.text = "\(Int(hour.temp_c))°"
        loadImage(iconPath: hour.condition.icon)
    }

    private func loadImage(iconPath: String) {
        let urlString = "https:\(iconPath)"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.iconImageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
