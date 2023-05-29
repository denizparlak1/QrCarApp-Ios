import SwiftUI

struct QRCodeSectionView: View {
    @Binding var qrCodeUrl: String
    @State private var showingDownloadAlert = false
    @State private var showingActivityView = false
    @State private var qrCodeData: Data?
    
    var body: some View {
        Section() {
            Button(action: {
                downloadQRCode()
            }, label: {
                HStack {
                    Image(systemName: "qrcode")
                        .foregroundColor(.accentColor)
                    Text("QR Kodu İndir")
                        .font(.headline)
                }
            })
            .sheet(isPresented: $showingActivityView) {
                let tempDirectoryURL = FileManager.default.temporaryDirectory
                let fileURL = tempDirectoryURL.appendingPathComponent("QRCode.svg")
                ActivityViewController(items: [fileURL])
            }

        }
    }
    
    

    private func downloadQRCode() {
        guard let url = URL(string: qrCodeUrl) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.qrCodeData = data
                    let fileName = "QRCode.svg"
                    let tempDirectoryURL = FileManager.default.temporaryDirectory
                    let fileURL = tempDirectoryURL.appendingPathComponent(fileName)
                    do {
                        try data.write(to: fileURL)
                        self.showingActivityView = true
                    } catch {
                        print("Error writing the SVG file: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Error downloading QR code: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }

}

struct QRCodeSectionView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeSectionView(qrCodeUrl: .constant("https://example.com/qrcode.png"))
    }
}
