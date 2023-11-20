import SwiftUI
import Combine

struct UserDetailsView: View {
    @State var mail: String
    @State var userId: String
    @State private var qrCodeUrl: String = ""

    @State private var showResetPasswordView = false
    @State private var showResetEmailView = false
    @State private var showInAppPurchaseView = false

    @State private var shareOnWhatsApp = false
    @State private var shareOnTelegram = false
    @State private var shareSMS = false
    @State private var namePermission = false
    @State private var phonePermission = false

    @StateObject var viewModel = UserViewModel()


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

            ShareSwitchView(shareOnWhatsApp: $viewModel.shareOnWhatsApp, shareOnTelegram: $viewModel.shareOnTelegram, shareSMS: $viewModel.shareSMS, namePermission: $viewModel.namePermission, phonePermission: $viewModel.phonePermission, userId: userId)
            
            VStack {
                Button(action: {
                    showInAppPurchaseView = true
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle") // Replace with the desired icon
                            .font(.system(size: 24))
                        Text("Mesaj Satın Al")
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    guard let qrCodeUrl = viewModel.qr,
                          let url = URL(string: qrCodeUrl) else {
                        return
                    }
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("QR Kod İndir")
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(
            NavigationLink("", destination: ResetPasswordView(userId: userId), isActive: $showResetPasswordView)
                .opacity(0)
        )
        .sheet(isPresented: $showResetEmailView) {
            EditEmailView(userId: userId, mail: $viewModel.mail, isPresented: $showResetEmailView)
        }
        .onAppear {
            viewModel.fetchUserData(userId: userId)
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(mail: "sample_user_mail", userId: "sample_user_id")
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

