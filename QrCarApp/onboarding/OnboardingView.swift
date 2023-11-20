import SwiftUI

struct OnboardingView: View {
    let userId: String
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingProgress: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isAnimating: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @State private var success: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Kayıt Ol")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)

                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(25)
                    .padding(.horizontal, 30)

                if isAnimating {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.green)
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0)
                        .transition(.scale)
                }

                Button(action: {
                    if email.isEmpty || password.isEmpty {
                        showAlert = true
                        alertMessage = "Lütfen email ve şifreyi doldurun"
                    } else {
                        isShowingProgress = true
                        // Call API to update email and password
                        UpdateEmailAndPasswordApi.updateEmail(userId: userId, email: email) { result in
                            // Handle API response
                            switch result {
                            case .success(let response):
                                print(response)
                            case .failure(let error):
                                print(error)
                            }
                            isShowingProgress = false
                        }

                        UpdateEmailAndPasswordApi.updatePassword(userId: userId, password: password) { result in
                            // Handle API response
                            switch result {
                            case .success(let response):
                                print(response)
                            case .failure(let error):
                                print(error)
                            }
                            isShowingProgress = false
                        }
                        UpdateOnboardingPermissionApi.updateOnboardingPermission(userId: userId) { result in
                            switch result {
                            case .success(let response):
                                success = true
                                showAlert = true
                                alertMessage = "Kayıt işlemi tamamlandı"
                                withAnimation(.easeIn(duration: 2.0)) {
                                    isAnimating = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            case .failure(let error):
                                showAlert = true
                                alertMessage = "Bir hata oluştu, lütfen tekrar deneyin"
                            }
                        }
                    }
                }) {
                    Text("Onayla")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.green))
                        .padding(.horizontal, 30)
                }
                .alert(isPresented: $showAlert) {
                    if success {
                        return Alert(title: Text("Artık Hazırsın"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                            // Empty
                        }))
                    } else {
                        return Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }

                if isShowingProgress {
                    ProgressView("Updating...")
                        .padding(.top, 20)
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(userId: "some_user_id")
    }
}
