import Foundation

struct UpdateOnboardingPermissionApi {
    struct UpdateUserOnboardingPermission: Codable {
        let user_id: String
    }

    static func updateOnboardingPermission(userId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/onboarding/permission/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserOnboardingPermission(user_id: userId)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating onboarding permission: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                if let data = data {
                    let response = try? JSONDecoder().decode(Bool.self, from: data)
                    print(response ?? false)
                    completion(.success(response ?? false))
                }
            }
        }.resume()
    }
}
