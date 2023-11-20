import Foundation

func updateMessage(userId: String, newMessage: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
    let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/message")!
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = UpdateUserMessage(user_id: userId, message: newMessage)
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
