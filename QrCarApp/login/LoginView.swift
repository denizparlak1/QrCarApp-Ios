import SwiftUI
import FirebaseAuth
import Combine

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isAuthenticated = false
    @State private var userId: String? = nil
    @State private var mail: String? = nil
    @State private var showingScanner = false
    @State private var isPasswordVisible = false
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var showOnboardingView = false
    @StateObject var userViewModel = UserViewModel()

    @ObservedObject var authViewModel = AuthViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 40)
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("Kullanıcı Adı")
                            .font(.headline)
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                        
                        Text("Şifre")
                            .font(.headline)
                        
                        ZStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            } else {
                                SecureField("Password", text: $password)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 12)
                            
                            }
                            
                        }
                        
                        HStack {
                            
                            Button(action: signIn) {
                                Text("Giriş Yap")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accentColor)
                                    .cornerRadius(8)
                            }
                            Spacer()
                            
                            NavigationLink(destination: ResetPassword(), label: {
                                HStack {
                                    Image(systemName: "person.fill.questionmark")
                                        .foregroundColor(.gray)
                                    Text("Şifremi Unuttum")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            })
                        }
                        .padding(.top, 20)
                        
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    
                }
                    .padding(.horizontal, 32)

                VStack(alignment: .leading){
                Button(action: {
                    showingScanner = true
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                            .foregroundColor(.accentColor)
                        Text("Kayıt Ol")
                            .font(.headline)
                        
                        
                    }
                    .padding(.top, 10)
                    .sheet(isPresented: $showingScanner) {
                        QRScannerView { code in
                            handleScannedQRCode(code: code)
                        }
                    }
                    
                }

                    .padding(.top, 10)
                    NavigationLink(
                        destination: OnboardingView(userId: userViewModel.userId ?? ""),
                        isActive: $showOnboardingView
                    ) {
                        EmptyView()
                    }
                    NavigationLink(
                        destination: authViewModel.userId.map { UserView(userId: $0, mail: authViewModel.userEmail ?? "") },
                        isActive: $authViewModel.isLoggedIn
                    ) {
                        EmptyView()
                    }
                    Spacer()
                }
                
                .padding()
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    

    func signIn() {
        UIApplication.shared.endEditing()

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                userId = result?.user.uid
                mail = result?.user.email
                isAuthenticated = true
                
            }
        }
    }
    
    func handleScannedQRCode(code: String) {
        showingScanner = false
        print("Scanned QR code: \(code)")

        if let url = URL(string: code), let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            if let userId = components.path.split(separator: "/").last {
                userViewModel.fetchUserData(userId: String(userId))
            }
        }

        userViewModel.$first_login.sink { first_login in
            if first_login {
                print("First login, redirecting to onboarding page...")
                userId = userViewModel.userId
                showOnboardingView = true
            }
        }.store(in: &cancellables)
    }



}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
