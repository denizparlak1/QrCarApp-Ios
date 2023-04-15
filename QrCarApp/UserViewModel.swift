import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var plateNumber: String = "Loading..."
    @Published var phoneNumber: String = "Loading..."
    @Published var parkMessage: String = "Loading..."
    @Published var mail: String = "Loading..."
    @Published var photoUrlString: String?
    @Published var qr: String?
    
    @Published var telegram_permission: Bool = true
    @Published var whatsapp_permission: Bool = true
    @Published var phone_permission: Bool = true

    private var cancellable: AnyCancellable?
    
    func fetchUserData(userId: String?) {
        guard let userId = userId else { return }
        
        isLoading = true
        
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/users/\(userId)")!
        
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
                self.plateNumber = userData.plate
                self.phoneNumber = userData.phone
                self.parkMessage = userData.message
                self.photoUrlString = userData.photo
                self.mail = userData.mail
                self.qr = userData.qr
                self.telegram_permission = userData.telegram_permission
                self.whatsapp_permission = userData.whatsapp_permission
                self.phone_permission = userData.phone_permission
                
                
                
            })
    }
}
