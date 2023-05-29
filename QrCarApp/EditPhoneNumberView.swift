import SwiftUI

struct UpdateUserPhone: Codable {
    let user_id: String
    let phone: String
}

struct EditPhoneNumberView: View {
    let userId: String
    @Binding var phoneNumber: String
    @Binding var isPresented: Bool
    @State private var isLoading = false
    @State private var tempPhoneNumber: String
    @State private var numberFormatter = NumberFormatter()
    
    init(userId: String, phoneNumber: Binding<String>, isPresented: Binding<Bool>) {
        self.userId = userId
        _phoneNumber = phoneNumber
        _isPresented = isPresented
        _tempPhoneNumber = State(initialValue: phoneNumber.wrappedValue)
        
        numberFormatter.allowsFloats = false
        numberFormatter.numberStyle = .decimal
    }
    
    var body: some View {
        VStack {
            Text("Yeni telefon numaranızı yazın")
                .font(.headline)
            TextField("Yeni telefon numaranızı yazın", text: $tempPhoneNumber)
                .keyboardType(.numberPad) // Add this line to show number pad keyboard
                .onChange(of: tempPhoneNumber) { newValue in
                    if let _ = numberFormatter.number(from: newValue) {
                        // The newValue is a valid number
                    } else {
                        // The newValue is not a valid number, revert to the previous value
                        tempPhoneNumber = String(newValue.dropLast())
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.bottom, 10)

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
        updatePhoneNumber(userId: userId, newPhoneNumber: tempPhoneNumber) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    print(response)
                    self.phoneNumber = tempPhoneNumber
                    isPresented = false
                case .failure(let error):
                    print("Error updating phone number: \(error.localizedDescription)")
                }
            }
        }

    }


}
