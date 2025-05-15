//
//  DailyCell.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 15.05.2025.
//

import Foundation
import UIKit

class DailyCell: UITableViewCell {
    static let identifier = "DailyCell"

    let dateLabel = UILabel()
    let iconImageView = UIImageView()
    let tempLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        dateLabel.font = .systemFont(ofSize: 16)
        dateLabel.textColor = .white

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true

        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        tempLabel.textColor = .white
        tempLabel.textAlignment = .right

        let stack = UIStackView(arrangedSubviews: [dateLabel, iconImageView, tempLabel])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with day: ForecastDay) {
        dateLabel.text = format(dateString: day.date)
        tempLabel.text = "\(Int(day.day.mintemp_c))° / \(Int(day.day.maxtemp_c))°"
        loadImage(iconPath: day.day.condition.icon)
    }

    private func format(dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        }
        return dateString
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
