import SwiftUI

struct EditProfileButton: View {
    @Binding var showUserDetailsView: Bool
    var userId: String
    var mail: String
    var qr: String
    var telegram_permission: Bool
    var whatsapp_permission: Bool
    var phone_permission: Bool
    
    var body: some View {
        Button(action: {
            showUserDetailsView = true
        }, label: {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.accentColor)
                Text("Ayarlar")
                    .foregroundColor(.accentColor)
            }
        })
        .background(
            NavigationLink("", destination: UserDetailsView(mail: mail, userId: userId,telegram_permission: telegram_permission,whatsapp_permission: whatsapp_permission,phone_permission: phone_permission, qr: Binding.constant(qr)), isActive: $showUserDetailsView)
                .opacity(0)
        )
    }
}
