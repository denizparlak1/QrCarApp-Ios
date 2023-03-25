//
//  ShareSwitchView.swift
//  QrCarApp
//
//  Created by Deniz Parlak on 25.03.2023.
//

import SwiftUI

struct ShareSwitchView: View {
    @State private var shareOnWhatsApp = false
    @State private var shareOnTelegram = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                Text("Share on WhatsApp")
                Spacer()
                Toggle("", isOn: $shareOnWhatsApp)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                Text("Share on Telegram")
                Spacer()
                Toggle("", isOn: $shareOnTelegram)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
        }
        .padding()
    }
}


struct ShareSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSwitchView()
    }
}
