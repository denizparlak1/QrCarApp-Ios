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
    
    private let imageUploader = ImageUploader()
    @Environment(\.presentationMode) var presentationMode
        

    var body: some View {
        
        VStack(alignment: .leading) {
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
                    }
                    
                
                
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.accentColor)
                        Text("Araç Plakası")
                            .font(.headline)
                        Button(action: {
                            showPlatePopup = true
                        }, label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        })
                    }
                    
                    
                    Text("🇹🇷 "+viewModel.plateNumber)
                        .font(.system(size: 20, design: .monospaced))

                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.accentColor)
                        Text("Telefon Numaram")
                            .font(.headline)
                        Button(action: {
                            showPhoneNumberPopup = true
                        }, label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        })
                    }
                        Text(viewModel.phoneNumber)
                    

                    HStack {
                        Image(systemName: "message.fill")
                            .foregroundColor(.accentColor)
                        Text("Park Mesajı")
                            .font(.headline)
                        Button(action: {
                            showMessagePopup = true
                        }, label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        })
                    }
                    Text(viewModel.parkMessage)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                
            }
        }


        .onAppear {
            viewModel.fetchUserData(userId: userId)
        }
        .navigationTitle("Hesabım")
        .navigationBarItems(leading: Button(action: logout, label: {
            Text("Çıkış")
                .foregroundColor(.accentColor)
        }))
        .navigationBarItems(trailing:
                                NavigationLink(destination: UserDetailsView(mail: mail, userId: userId,telegram_permission:viewModel.telegram_permission,whatsapp_permission: viewModel.whatsapp_permission,phone_permission: viewModel.phone_permission, qr: $viewModel.qr)) {
                Text("Ayarlar")
                    .foregroundColor(.accentColor)
            }
        )
        .navigationBarBackButtonHidden(true)


        .sheet(isPresented: $showPhoneNumberPopup, content: {
            EditPhoneNumberView(userId: userId, phoneNumber: $viewModel.phoneNumber, isPresented: $showPhoneNumberPopup)
        })
        .sheet(isPresented: $showMessagePopup, content: {
            EditMessageView(userId: userId, message: $viewModel.parkMessage, isPresented: $showMessagePopup)
        })
        .sheet(isPresented: $showPlatePopup, content: {
            EditPlateView(userId: userId, plate: $viewModel.plateNumber, isPresented: $showPlatePopup)
        })
        .sheet(isPresented: $showImagePicker, content: {
            ImagePicker { image in
                // Handle the selected image here, e.g., upload the image to the server
                ImageUploader.uploadProfileImage(userId: userId, image: image) { result in
                    switch result {
                    case .success(let imageURL):
                        print("Image uploaded successfully, URL: \(imageURL)")
                        DispatchQueue.main.async {
                            viewModel.photoUrlString = imageURL
                            viewModel.fetchUserData(userId: userId) // Refresh user data
                        }
                    case .failure(let error):
                        print("Error uploading image: \(error.localizedDescription)")
                    }
                }

            }
        })

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
