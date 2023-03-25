import SwiftUI
import Firebase

struct UpdateEmail: Codable {
    let user_id: String
    let email: String
}

struct EditEmailView: View {
    let userId: String
    let textFieldText: String = ""
    @Binding var mail: String
    @Binding var isPresented: Bool
    @State private var tempEmail: String = ""
    @State private var isLoading = false
    
    @State private var alertMessage: String = ""
    @State private var isAlertPresented: Bool = false
    
    
    

    init(userId: String, mail: Binding<String>, isPresented: Binding<Bool>) {
        self.userId = userId
        _mail = mail
        _isPresented = isPresented

        _tempEmail = State(initialValue: mail.wrappedValue)
    }

    var body: some View {
        VStack {
            Text("Mail adresinizi yazın")
                .font(.headline)
            TextField("Yeni mail adresinizi yazın", text: $tempEmail)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                HStack(spacing: 10) {
                    Button(action: saveButtonTapped, label: {
                        Text("Kaydet")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Text("Kapat")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    })
                }
            }
        }
        .padding()
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Sonuç"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 200) {
                }
            }))
        }

        
    }

    func saveButtonTapped() {
        isLoading = true
        let currentUser = Auth.auth().currentUser
        
        currentUser?.updateEmail(to: tempEmail) { error in
            if let error = error {
                isLoading = false
                alertMessage = "Mail adresi sistemde kayıtlı!"
                isAlertPresented = true
                return
            } else {
                updateEmail(userId: userId, email: tempEmail)
                DispatchQueue.main.async() {
                    isLoading = false
                    alertMessage = "Mail adresi güncellendi, değişikler için tekrar giriş yapın!"
                    isAlertPresented = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 100.0) {
                    isAlertPresented = false
                    isPresented = false
                }
                isPresented = false
            }
        }
    }





    func updateEmail(userId: String, email: String) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/email/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateEmail(user_id: userId, email: tempEmail)
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
                self.mail = tempEmail
                isPresented = false


            }
        }.resume()
    }
}
