import SwiftUI

struct UpdateUserMessage: Codable {
    let user_id: String
    let message: String
}

struct EditMessageView: View {
    let userId: String
    @Binding var message: String
    @Binding var isPresented: Bool
    @State private var tempMessage: String 
    @State private var isLoading = false
    
    init(userId: String, message: Binding<String>, isPresented: Binding<Bool>) {
        self.userId = userId
        _message = message
        _isPresented = isPresented
        _tempMessage = State(initialValue: message.wrappedValue) // Initialize the tempMessage
    }

    var body: some View {
        VStack {
            Text("Mesajınızı yazın")
                .font(.headline)
            TextField("Enter new phone number", text: $tempMessage)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: saveButtonTapped, label: {
                    Text("Kaydet")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
            }
        }
        .padding()
    }

    func saveButtonTapped() {
        isLoading = true
        updateMessage(userId: userId, newMessage: tempMessage)
    }

    func updateMessage(userId: String, newMessage: String) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/message")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateUserMessage(user_id: userId, message: newMessage)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error updating message: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    let response = try? JSONDecoder().decode([String: String].self, from: data)
                    print(response ?? "No response")
                }
                self.message = tempMessage
                isPresented = false
            }
        }.resume()
    }
}

