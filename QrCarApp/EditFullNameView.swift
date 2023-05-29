import SwiftUI

struct UpdateUserName: Codable {
    let user_id: String
    let fullname: String
}

struct EditFullNameView: View {
    let userId: String
    @Binding var fullName: String
    @Binding var isPresented: Bool
    @State private var isLoading = false
    @State private var tempFullName: String
    
    init(userId: String, fullName: Binding<String>, isPresented: Binding<Bool>) {
        self.userId = userId
        _fullName = fullName
        _isPresented = isPresented
        _tempFullName = State(initialValue: fullName.wrappedValue)
    }
    
    var body: some View {
        VStack {
            Text("Adınızı yazın")
                .font(.headline)
            TextField("", text: $tempFullName)
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
        updateFullName(userId: userId, newFullName: tempFullName) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    print(response)
                    self.fullName = tempFullName
                    isPresented = false
                case .failure(let error):
                    print("Error updating full name: \(error.localizedDescription)")
                }
            }
        }
    }



}
