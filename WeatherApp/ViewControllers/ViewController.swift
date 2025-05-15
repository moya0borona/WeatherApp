//
//  ViewController.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 14.05.2025.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var hourlyForecast: [Hour] = []
    var dailyForecast: [ForecastDay] = []
    
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        return indicator
    }()

    var locationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 120, weight: .thin)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 70, height: 100)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        collectionView.layer.cornerRadius = 15
        collectionView.clipsToBounds = true
        
        return collectionView
    }()

    var dailyTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
       
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 15
        tableView.clipsToBounds = true
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        checkLocationStatus()
        
        view.addSubview(activityIndicator)
        view.addSubview(locationLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(hourlyCollectionView)
        view.addSubview(dailyTableView)
        
        hourlyCollectionView.dataSource = self
        hourlyCollectionView.register(HourlyCell.self, forCellWithReuseIdentifier: HourlyCell.identifier)
        
        dailyTableView.dataSource = self
        dailyTableView.register(DailyCell.self, forCellReuseIdentifier: DailyCell.identifier)
        
        setConstraints()
    }
    
    func updateWeather() {
        LocationServices.shared.locationManager.requestLocation()
    }
    
    func checkLocationStatus() {
        let locationManager = LocationServices.shared.locationManager
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            LocationServices.shared.userLocationDelegate = self
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func fetchWeather(latitude: Double, longitude: Double) {

        activityIndicator.startAnimating()
        
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String else {
            print("API Key not found")
            return
        }
        
        let urlString = "http://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(latitude),\(longitude)&days=3&aqi=no&alerts=no"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        Task {
            do {
                let weatherInfo: WeatherData = try await NetworkManager.shared.fetchData(from: url)

                let now = Date()

                var filteredHours: [Hour] = []

                for (index, day) in weatherInfo.forecast.forecastday.enumerated() {
                    if index == 0 {
                        let currentDayHours = day.hour.filter {
                            guard let hourDate = $0.date else { return false }
                            return hourDate > now
                        }
                        filteredHours.append(contentsOf: currentDayHours)
                    } else if index == 1 {
                        filteredHours.append(contentsOf: day.hour)
                    }
                }

                let daily = weatherInfo.forecast.forecastday

                await MainActor.run {
                    self.temperatureLabel.text = "\(Int(weatherInfo.current.temp_c))°"
                    self.locationLabel.text = weatherInfo.location.name
                    
                    self.hourlyForecast = filteredHours
                    self.hourlyCollectionView.reloadData()
                    
                    self.dailyForecast = daily
                    self.dailyTableView.reloadData()
                
                    self.activityIndicator.stopAnimating()
                }
            } catch {
                await MainActor.run {
                    self.showErrorAlert(message: "Ошибка загрузки данных.\nПроверьте подключение к интернету.")
                }
            }
        }
}
    
    func showErrorAlert(message: String) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { _ in
            
            if let location = LocationServices.shared.locationManager.location {
                self.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            } else {
                self.updateWeather()
            }
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            
            hourlyCollectionView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 40),
            hourlyCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            hourlyCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            dailyTableView.topAnchor.constraint(equalTo: hourlyCollectionView.bottomAnchor, constant: 16),
            dailyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dailyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dailyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        ])
    }
}

extension ViewController: CustomUserLocationDelegate {
    func userLocationUpdated(location: CLLocation) {
        fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCell.identifier, for: indexPath) as! HourlyCell
        cell.configure(with: hourlyForecast[indexPath.item])
        return cell
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyForecast.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DailyCell.identifier, for: indexPath) as! DailyCell
        cell.configure(with: dailyForecast[indexPath.row])
        return cell
    }
}

    


