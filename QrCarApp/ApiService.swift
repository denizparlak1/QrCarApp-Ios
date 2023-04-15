import Foundation

class ApiService {
    static let shared = ApiService()

    private init() { }
    
    func updateTelegramPermission(userId: String, permission: Bool) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/telegram/permission")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserTelegramPermission(user_id: userId, permission: permission)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating plate: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    let response = try? JSONDecoder().decode([String: String].self, from: data)
                    print(response ?? "No response")
                }
            }
        }.resume()
    }


    // Add other API functions here
}
