import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Şifrenizi sıfırlamak için lütfen e-posta adresinizi girin.")
                .font(.headline)
                .padding()
            
            TextField("E-posta", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5.0)
                .padding(.horizontal)
            
            Button(action: resetPassword) {
                Text("Şifremi Sıfırla")
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            .padding(.top)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Spacer()
        }
        .navigationBarTitle("Şifremi Unuttum")
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.successMessage = ""
            } else {
                self.errorMessage = ""
                self.successMessage = "Şifre sıfırlama e-postası gönderildi!"
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
