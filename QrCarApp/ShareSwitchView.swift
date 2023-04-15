import SwiftUI

struct TelegramUsernameSheet: View {
    let userId: String
    @Binding var telegramUsername: String
    @Binding var isVisible: Bool
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Telegram Kullanıcı Adınız Girin")
                .font(.headline)
            TextField("Kullanıcı Adı", text: $telegramUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: saveButtonTapped,label: {
                Text("Kaydet")})
            .padding()
        }
        .padding()
    }
    
    func saveButtonTapped() {
        isLoading = true
        updateTelegramLink(userId: userId, telegram: telegramUsername)
        ApiService.shared.updateTelegramPermission(userId: userId, permission: true)
        isVisible = false
        
    }
    
    
    func updateTelegramLink(userId: String, telegram: String) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/telegram")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserTelegram(user_id: userId, telegram: telegram)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                isLoading = false
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
    
    
    

}

struct UpdateUserTelegram: Codable {
    let user_id: String
    let telegram: String
}

struct UpdateUserTelegramPermission: Codable {
    let user_id: String
    let permission: Bool
}
