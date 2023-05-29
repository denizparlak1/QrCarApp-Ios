import SwiftUI
import Foundation

struct ShareSwitchView: View {
    @Binding var shareOnWhatsApp: Bool
    @Binding var shareOnTelegram: Bool
    @Binding var shareSMS: Bool
    @Binding var namePermission: Bool
    @Binding var phonePermission: Bool
    let userId: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "message.circle.fill").foregroundColor(.green)
                Text("Whatsapp iletişim izni")
                Spacer()
                Toggle("", isOn: $shareOnWhatsApp)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .onChange(of: shareOnWhatsApp) { newValue in
                        WhatsappShareUpdateApi.updateShareOnWhatsApp(userId: userId, shareOnWhatsApp: newValue)
                    }
            }
            HStack {
                Image(systemName: "paperplane.fill").foregroundColor(.blue)
                Text("Telegram iletişim izni")
                Spacer()
                Toggle("", isOn: $shareOnTelegram)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: shareOnTelegram) { newValue in
                        TelegramShareUpdateApi.updateShareOnTelegram(userId: userId, shareOnTelegram: newValue)
                    }
            }
            HStack {
                Image(systemName: "text.bubble")
                Text("SMS iletişim izni")
                Spacer()
                Toggle("", isOn: $shareSMS)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: shareSMS) { newValue in
                        SmsShareUpdateApi.updateShareOnSMS(userId: userId, shareSMS: newValue)
                    }
                
            }
            HStack {
                Image(systemName: "person.fill")
                Text("İsim görürlük izni")
                Spacer()
                Toggle("", isOn: $namePermission)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: namePermission) { newValue in
                        UpdateNamePermissionApi.updateNamePermission(userId:userId, name_permission: newValue)
                                }
                            
                        }
            
            HStack {
                Image(systemName: "phone.fill")
                Text("Telefon ile arama izni")
                Spacer()
                Toggle("", isOn: $phonePermission)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .onChange(of: phonePermission) { newValue in
                        PhoneCallPermissionUpdateApi.updatePhoneCallPermission(userId:userId, phonePermission: newValue)
                                }
                            
                        }

        }
        .padding()
    }
}

struct ShareSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSwitchView(shareOnWhatsApp: .constant(false), shareOnTelegram: .constant(false), shareSMS: .constant(false), namePermission: .constant(false),phonePermission: .constant(false),  userId: "user_id")

    }
}
