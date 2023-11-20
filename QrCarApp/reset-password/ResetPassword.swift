import SwiftUI
import FirebaseAuth

struct ResetPassword: View {
    @State private var email: String = ""
    @State private var isEmailSent: Bool = false
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            // GIF Image at the top
            Image("forgot-password")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .padding(.top, 20)
            
            // Email Field
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            
            // Send Button
            Button(action: resetPassword) {
                Text("Şifre Sıfırla")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Şifre Sıfırlama Başarılı!"), message: Text("Yeni şifrenizi oluşturmak için email adresinizi kontrol edin!"), dismissButton: .default(Text("OK")))
        }
    }
    
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Password reset error: \(error.localizedDescription)")
            } else {
                isEmailSent = true
                showAlert = true
            }
        }
    }
}

struct ResetPassword_Previews: PreviewProvider {
    static var previews: some View {
        ResetPassword()
    }
}
