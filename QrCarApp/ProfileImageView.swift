//
//  ProfileImageView.swift
//  QrCarApp
//
//  Created by Deniz Parlak on 23.03.2023.
//

import SwiftUI
import URLImage

struct ProfileImageView: View {
    let photoUrlString: String

    var body: some View {
        if let url = URL(string: photoUrlString) {
            URLImage(url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 110, height: 110)
                    .clipShape(Circle())
            }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 90, height: 90)
                .foregroundColor(.gray)
        }
    }
}

