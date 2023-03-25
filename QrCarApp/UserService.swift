import Foundation
import Combine

class UserService {
    private let decoder = JSONDecoder()
    
    func resetPassword(userId: String, newPassword: String) -> AnyPublisher<Void, Error> {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/password/")!
        let userPassword = UpdateUserPassword(user_id: userId, password: newPassword)
        
        do {
            let requestBody = try JSONEncoder().encode(userPassword)
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestBody
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                    return ()
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail<Void, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}

struct UpdateUserPassword: Codable {
    let user_id: String
    let password: String
}

