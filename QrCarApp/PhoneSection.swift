import SwiftUI

struct PhoneSection: View {
    @ObservedObject var viewModel: UserViewModel
    @Binding var showPhoneNumberPopup: Bool

    var body: some View {
        VStack(alignment: .leading) {
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
        }
    }
}

struct PhoneSection_Previews: PreviewProvider {
    static var previews: some View {
        PhoneSection(viewModel: UserViewModel(), showPhoneNumberPopup: .constant(false))
    }
}
