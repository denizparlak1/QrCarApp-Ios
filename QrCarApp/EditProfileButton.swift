import SwiftUI

struct EditProfileButton: View {
    @Binding var showUserDetailsView: Bool
    var userId: String
    var mail: String
    var whatsapp_permission: Bool
    var telegram_permission: Bool
    var sms_permission: Bool

    
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
            NavigationLink("", destination: UserDetailsView(mail: mail, userId: userId), isActive: $showUserDetailsView)
                .opacity(0)
        )
    }
}
