import SwiftUI
import Combine
import WebKit

struct UserDetailsView: View {
    @State var mail: String
    @State var userId: String
    @State var telegram_permission: Bool
    @State var whatsapp_permission: Bool
    @State var phone_permission: Bool
    
    @State private var telegramUsername = ""
    @State private var showResetPasswordView = false
    @State private var showResetEmailView = false


    @State private var showTelegramUsernameSheet = false
    
    @State private var isDownload = false
    
    @ObservedObject var viewModel = UserViewModel()
    
    
    @Binding var qr: String?
    
    private func handleShareOnTelegramToggle(isOn: Bool) {
        if isOn {
            showTelegramUsernameSheet = true
        } else {
            ApiService.shared.updateTelegramPermission(userId: userId, permission: false)
        }
        viewModel.fetchUserData(userId: userId)
        
    }
    
    func downloadSVG(urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    let fileManager = FileManager.default
                    let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let newFileURL = documentsURL.appendingPathComponent("qrcode.svg")

                    if fileManager.fileExists(atPath: newFileURL.path) {
                        try fileManager.removeItem(at: newFileURL)
                    }
                    
                    try fileManager.moveItem(at: tempLocalUrl, to: newFileURL)
                    completion(.success(newFileURL))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error!))
            }
        }
        task.resume()
    }

    
    
    var body: some View {
        Form {
            Section(header: Text("Account Information")) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.accentColor)
                    Text(mail)
                        .font(.headline)

                    Button(action: {
                        showResetEmailView = true
                    }, label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.accentColor)
                    })
                }
                

                Button(action: {
                    showResetPasswordView = true
                }, label: {
                    Text("Şifre Değiştir")
                        .foregroundColor(.red)
                })
                
            }
            HStack {
                Image(systemName: "message.circle")
                Text("Whatsap ile iletişimi paylaş")
                Spacer()
                Toggle("", isOn: $whatsapp_permission)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            HStack {
                Image(systemName: "arrow.up.circle")
                Text("Telegram ile iletişimi paylaş")
                Spacer()
                Toggle("", isOn: $telegram_permission)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: telegram_permission, perform: handleShareOnTelegramToggle)
            }
            
            HStack {
                Image(systemName: "phone.circle")
                Text("Telefon ile arama izni")
                Spacer()
                Toggle("", isOn: $phone_permission)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: phone_permission, perform: handleShareOnTelegramToggle)
            }
            
            HStack {
                if let qr = qr {
                    GeometryReader { geometry in
                        WebView(urlString: qr)
                            .frame(width: min(geometry.size.width, geometry.size.height) * 0.8, height: min(geometry.size.width, geometry.size.height) * 0.8)
                    }
                } else {
                    Text("Failed to load QR code")
                }

                Button(action: {
                    if let qr = qr {
                        downloadSVG(urlString: qr) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let fileURL):
                                    let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                                    UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
                                case .failure(let error):
                                    print("Error downloading SVG: \(error)")
                                }
                            }
                        }
                    }
                }) {
                    Text("İndir")
                }
            }
        }

        .background(
            NavigationLink("", destination: ResetPasswordView(userId: userId), isActive: $showResetPasswordView)
                .opacity(0)
        )
        .sheet(isPresented: $showResetEmailView) {
            EditEmailView(userId: userId, mail: $viewModel.mail, isPresented: $showResetEmailView)
        }
        
        .sheet(isPresented: $showTelegramUsernameSheet) {
            TelegramUsernameSheet(userId: userId, telegramUsername: $telegramUsername, isVisible: $showTelegramUsernameSheet)
        }
        


        .onAppear {
            viewModel.fetchUserData(userId: userId)
            print("shareOnTelegram:", telegram_permission)
        }


        .onChange(of: viewModel.mail) { mail in
            self.mail = mail
        }

    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(mail: "sample_user_mail", userId: "sample_user_id",telegram_permission: true,whatsapp_permission: true,phone_permission: true, qr: .constant("sample_qr_url"))
    }
}





struct ResetPasswordView: View {
    @State var userId: String
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var userService = UserService()
    @State private var cancellable: AnyCancellable?
    @State private var isLoading = false
    @State private var errorMessage = ""

    private var isPasswordValid: Bool {
        newPassword == confirmPassword && newPassword.count >= 6
    }

    var body: some View {
        Form {
            Section() {
                SecureTextField(placeholder: "Yeni şifre", text: $newPassword)
                SecureTextField(placeholder: "Yeni şifreyi tekrar girin", text: $confirmPassword)
            }

            if !isLoading {
                Button(action: resetPassword) {
                    Text("Onayla")
                }
                .disabled(!isPasswordValid)
                .opacity(isPasswordValid ? 1.0 : 0.3)
            } else {
                ProgressView()
            }

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Çıkış")
            })
            .foregroundColor(.red)
        }
        .navigationTitle("Şifre Sıfırlama")
    }

    private func resetPassword() {
        isLoading = true
        cancellable = userService.resetPassword(userId: userId, newPassword: newPassword)
            .sink(receiveCompletion: { completion in
                isLoading = false
                switch completion {
                case .failure(let error):
                    errorMessage = "Şifre güncellenirken hata oluştu!: \(error.localizedDescription)"
                case .finished:
                    errorMessage = ""
                    presentationMode.wrappedValue.dismiss()
                    // Show success message to user
                    let message = "Şifre güncellendi"
                    let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                }
            }, receiveValue: { _ in })
    }
}

struct SecureTextField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(.accentColor)
            }
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(userId: "sample_user_id")
    }
}

