import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userId: String?
    @Published var userEmail: String? = nil

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.userId = user.uid
                self.isLoggedIn = true
                self.userEmail = user.email
            } else {
                self.userId = nil
                self.userEmail = nil
                self.isLoggedIn = false
            }
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
