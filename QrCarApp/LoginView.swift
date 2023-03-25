import SwiftUI
import FirebaseAuth

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
    @State private var isPasswordVisible = false
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

                    Text("Dijital Kimliğim")
                        .font(.largeTitle)
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
                    }
                    
                    .padding(.horizontal, 32)

                    Button(action: signIn) {
                        Text("Giriş Yap")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(8)
                    }
                    .padding(.top, 40)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Login Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
