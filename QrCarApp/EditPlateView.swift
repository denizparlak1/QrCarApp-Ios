import SwiftUI

struct UpdatePlate: Codable {
    let user_id: String
    let plate: String
}

struct EditPlateView: View {
    let userId: String
    @Binding var plate: String
    @Binding var isPresented: Bool
    @State private var tempPlate: String // Add this line
    @State private var isLoading = false

    init(userId: String, plate: Binding<String>, isPresented: Binding<Bool>) {
        self.userId = userId
        _plate = plate
        _isPresented = isPresented
        _tempPlate = State(initialValue: plate.wrappedValue) // Initialize the tempPlate
    }

    var body: some View {
        VStack {
            Text("Plakanızı yazın")
                .font(.headline)
            TextField("Plakanızı yazın", text: $tempPlate) // Replace this line
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)
                .onChange(of: tempPlate) { newValue in
                    tempPlate = newValue.uppercased()
                }

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Button(action: saveButtonTapped, label: {
                    Text("Kaydet")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                })
            }
        }
        .padding()
    }

    func saveButtonTapped() {
        isLoading = true
        updatePlate(userId: userId, plate: tempPlate) // Pass tempPlate instead of plate
    }

    func updatePlate(userId: String, plate: String) {
        let url = URL(string: "https://qrcarapp-akzshgayzq-uc.a.run.app/user/update/plate")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdatePlate(user_id: userId, plate: plate)
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error updating plate: \(error.localizedDescription)")
                    return
                }

                if let data = data {
                    let response = try? JSONDecoder().decode([String: String].self, from: data)
                    print(response ?? "No response")
                }
                self.plate = tempPlate // Update the plate in UserViewModel
                isPresented = false
            }
        }.resume()
    }
}
