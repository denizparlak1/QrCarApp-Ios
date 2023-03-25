import UIKit
import AVFoundation


class ImageUploader {
    enum ImageFormat {
        case jpeg(compressionQuality: CGFloat)
        case png
        case heic(compressionQuality: CGFloat)
        
        var mimeType: String {
            switch self {
            case .jpeg:
                return "image/jpeg"
            case .png:
                return "image/png"
            case .heic:
                return "image/heic"
            }
        }
        
        var fileExtension: String {
            switch self {
            case .jpeg:
                return "jpg"
            case .png:
                return "png"
            case .heic:
                return "heic"
            }
        }
    }
    
    
    
    static func uploadProfileImage(userId: String, image: UIImage, format: ImageFormat = .jpeg(compressionQuality: 0.8), completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure that the image can be converted to the desired format
        guard let imageData = image.data(using: format) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to the desired format"])))
            return
        }
        
        // Create a URLRequest for the API endpoint
        let urlString = "https://qrcarapp-akzshgayzq-uc.a.run.app/users/add/avatar/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Create a unique boundary string for the multipart request
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        
        // Set the request body with the image data and boundary string
        request.httpBody = createRequestBody(imageData: imageData, format: format, boundary: boundary)
        
        // Send the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let responseString = try JSONDecoder().decode(String.self, from: data)
                    completion(.success(responseString))
                } catch let decodingError {
                    completion(.failure(decodingError))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }.resume()
    }
    
    private static func createRequestBody(imageData: Data, format: ImageFormat, boundary: String) -> Data {
        var body = Data()
        
        // Append the image data to the request body
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.\(format.fileExtension)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(format.mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Append the closing boundary string
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

extension UIImage {
    func data(using format: ImageUploader.ImageFormat) -> Data? {
        switch format {
        case .jpeg(let compressionQuality):
            return self.jpegData(compressionQuality: compressionQuality)
        case .png:
            return self.pngData()
        case .heic(let compressionQuality):
            if #available(iOS 11.0, *) {
                return self.heicData(compressionQuality: compressionQuality)
            } else {
                return nil
            }
        }
    }

    @available(iOS 11.0, *)
    func heicData(compressionQuality: CGFloat) -> Data? {
        let data = NSMutableData()
        if let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, AVFileType.heic as CFString, 1, nil),
           let cgImage = self.cgImage {
            let options: NSDictionary = [kCGImageDestinationLossyCompressionQuality as NSString: compressionQuality]
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            if CGImageDestinationFinalize(imageDestination) {
                return data as Data
            }
        }
        return nil
    }
}
