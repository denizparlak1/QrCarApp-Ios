import SwiftUI
import URLImage
import Firebase

struct UserView: View {
    let userId: String
    let mail: String
    
    @ObservedObject var viewModel = UserViewModel()
    @State private var showPhoneNumberPopup = false
    @State private var showMessagePopup = false
    @State private var showUserDetailsView = false
    @State private var showPlatePopup = false
    @State private var showImagePicker = false
    @State private var showNameEdit = false
    private let imageUploader = ImageUploader()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 20)
            } else {
                Section {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        ProfileImageView(photoUrlString: viewModel.photoUrlString ?? "")
                            .frame(width: min(150, UIScreen.main.bounds.width * 0.6), height: min(150, UIScreen.main.bounds.width * 0.6))
                    }
                    
                    Button(action: {
                        showNameEdit = true
                    }) {
                        HStack {
                            Text(viewModel.fullname)
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.accentColor)
                        Text("Araç Plakası")
                            .font(.headline)
                        Button(action: {
                            showPlatePopup = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    }
                    Text("🇹🇷 " + viewModel.plateNumber)
                        .font(.system(size: 20, design: .monospaced))
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor)
                        Text("Telefon Numaram")
                            .font(.headline)
                        Button(action: {
                            showPhoneNumberPopup = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    }
                    Text(viewModel.phoneNumber)
                    
                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.accentColor)
                        Text("Park Mesajı")
                            .font(.headline)
                        Button(action: {
                            showMessagePopup = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    }
                    ScrollView {
                        Text(viewModel.parkMessage)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                    }
                }
                .padding(.horizontal, min(32, UIScreen.main.bounds.width * 0.1))
                .padding(.top, 10)
            }
        }
        .onAppear {
            viewModel.fetchUserData(userId: userId)
        }
        .navigationTitle("Hesabım")
        .navigationBarItems(leading: Button(action: logout) {
            Text("Çıkış")
                .foregroundColor(.accentColor)
        })
        .navigationBarItems(trailing:
            NavigationLink(destination: UserDetailsView(mail: mail, userId: userId)) {
                Text("Ayarlar")
                    .foregroundColor(.accentColor)
            }
        )
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showNameEdit) {
            EditFullNameView(userId: userId, fullName: $viewModel.fullname, isPresented: $showNameEdit)
        }
        .sheet(isPresented: $showPhoneNumberPopup) {
            EditPhoneNumberView(userId: userId, phoneNumber: $viewModel.phoneNumber, isPresented: $showPhoneNumberPopup)
        }
        .sheet(isPresented: $showMessagePopup) {
            EditMessageView(userId: userId, message: $viewModel.parkMessage, isPresented: $showMessagePopup)
        }
        .sheet(isPresented: $showPlatePopup) {
            EditPlateView(userId: userId, plate: $viewModel.plateNumber, isPresented: $showPlatePopup)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker { image in
                ImageUploader.uploadProfileImage(userId: userId, image: image) { result in
                    switch result {
                    case .success(let imageURL):
                        print("Image uploaded successfully, URL: \(imageURL)")
                        DispatchQueue.main.async {
                            viewModel.photoUrlString = imageURL
                            viewModel.fetchUserData(userId: userId)
                        }
                    case .failure(let error):
                        print("Error uploading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(userId: "sample_user_id", mail: "sample_user_mail")
    }
}
