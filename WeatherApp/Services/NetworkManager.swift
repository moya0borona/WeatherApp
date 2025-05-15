//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Андрей Андриянов on 14.05.2025.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    func fetchData<T: Codable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        do {
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            throw error
        }
    }
}
