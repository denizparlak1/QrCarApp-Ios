import Foundation

struct UpdateNamePermissionApi {
    struct UpdateUserNamePermission: Codable {
        let user_id: String
        let permission: Bool
    }

    static func updateNamePermission(userId: String, name_permission: Bool) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/name/permission/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserNamePermission(user_id: userId, permission: name_permission)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating name permission: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    let response = try? JSONDecoder().decode([String: String].self, from: data)
                    print(response ?? "No response")
                }
            }
        }.resume()
    }
}
