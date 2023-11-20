import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var plateNumber: String = "Loading..."
    @Published var phoneNumber: String = "Loading..."
    @Published var parkMessage: String = "Loading..."
    @Published var fullname: String = "Loading..."
    @Published var mail: String = "Loading..."
    @Published var photoUrlString: String?
    @Published var qr: String?
    @Published var userId: String?
    @Published var shareOnWhatsApp: Bool = false
    @Published var shareOnTelegram: Bool = false
    @Published var shareSMS: Bool = false
    @Published var namePermission: Bool = false
    @Published var first_login: Bool = false
    @Published var phonePermission: Bool = false
    
    private var cancellable: AnyCancellable?
    
    
    
    func fetchUserData(userId: String?) {
        guard let userId = userId else { return }
        
        isLoading = true
        
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/users/\(userId)")!
        
        print("Fetching user data from: \(url)") // Print the URL
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: UserData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching user data: \(error.localizedDescription)")
                case .finished:
                    print("Finished fetching user data")
                    
                }
                self.isLoading = false
            }, receiveValue: { userData in
                print("Received user data: \(userData)") // Print the received user data
                
                self.plateNumber = userData.plate
                self.phoneNumber = userData.phone
                self.parkMessage = userData.message
                self.photoUrlString = userData.photo
                self.mail = userData.mail
                self.shareOnWhatsApp = userData.whatsapp_permission
                self.shareOnTelegram = userData.telegram_permission
                self.shareSMS = userData.sms_permission
                self.qr = userData.qr
                self.first_login = userData.first_login
                self.userId = userData.userId
                self.namePermission = userData.name_permission
                self.fullname = userData.fullname
                self.phonePermission = userData.phone_permission
                
            })
    }
}
