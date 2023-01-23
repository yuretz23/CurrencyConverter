//
//  NetworkManager.swift
//  CurrencyConverter_Yurii_Kalynchuk
//
//  Created by Yurii Kalynchuk on 22.01.2023.
//

import Foundation

enum HttpMethod: String {
    case get
    case post

    var method: String { rawValue.uppercased() }
}

protocol NetworkManagerProtocol {
    func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod, completion: @escaping (Result<T, Error>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    enum ManagerErrors: Error {
        case invalidResponse
        case invalidStatusCode(Int)
    }

    func request<T: Decodable>(fromURL url: URL, httpMethod: HttpMethod = .get, completion: @escaping (Result<T, Error>) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.method

        let urlSession = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else { return completion(.failure(ManagerErrors.invalidResponse)) }
            if !(200..<300).contains(urlResponse.statusCode) {
                return completion(.failure(ManagerErrors.invalidStatusCode(urlResponse.statusCode)))
            }

            guard let data = data else { return }
            do {
                let users = try JSONDecoder().decode(T.self, from: data)
                completion(.success(users))
            } catch {
                debugPrint("Could not translate the data to the requested type. Reason: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        urlSession.resume()
    }
}
