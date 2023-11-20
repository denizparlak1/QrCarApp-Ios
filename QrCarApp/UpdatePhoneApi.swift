//
//  UpdatePhoneApi.swift
//  QrCarApp
//
//  Created by Deniz Parlak on 1.05.2023.
//

import Foundation

func updatePhoneNumber(userId: String, newPhoneNumber: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/phone")!
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = UpdateUserPhone(user_id: userId, phone: newPhoneNumber)
    request.httpBody = try? JSONEncoder().encode(body)

    URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        if let data = data {
            do {
                let response = try JSONDecoder().decode([String: String].self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }
    }.resume()
}
