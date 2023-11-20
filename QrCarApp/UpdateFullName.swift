import Foundation

struct UpdateUserFullName: Codable {
    let user_id: String
    let fullname: String
}

func updateFullName(userId: String, newFullName: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/fullname")!
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = UpdateUserFullName(user_id: userId, fullname: newFullName)
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
