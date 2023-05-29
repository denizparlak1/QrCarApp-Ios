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
        updatePlate(userId: userId, plate: tempPlate) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    print(response)
                    self.plate = tempPlate
                    isPresented = false
                case .failure(let error):
                    print("Error updating plate: \(error.localizedDescription)")
                }
            }
        }

    }

}
