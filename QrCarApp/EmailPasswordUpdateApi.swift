import Foundation

struct UpdateEmailAndPasswordApi {
    struct UpdateUserEmail: Codable {
        let user_id: String
        let email: String
    }

    struct UpdateUserPassword: Codable {
        let user_id: String
        let password: String
    }

    static func updateEmail(userId: String, email: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/email/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserEmail(user_id: userId, email: email)
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

    static func updatePassword(userId: String, password: String, completion: @escaping (Result<[String: String], Error>) -> Void) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/password/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserPassword(user_id: userId, password: password)
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
}

