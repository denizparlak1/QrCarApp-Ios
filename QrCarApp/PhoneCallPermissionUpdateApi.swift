import Foundation

struct PhoneCallPermissionUpdateApi {
    struct UpdateUserShare: Codable {
        let user_id: String
        let permission: Bool
    }

    static func updatePhoneCallPermission(userId: String, phonePermission: Bool) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/phone/permission/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserShare(user_id: userId, permission: phonePermission)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error updating Call Permission status: \(error.localizedDescription)")
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
