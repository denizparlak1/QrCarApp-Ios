//
//  User.swift
//  QrCarApp
//
//  Created by Deniz Parlak on 23.03.2023.
//

import Foundation

struct UserData: Decodable {
    let plate: String
    let phone: String
    let message: String
    let photo: String
    let mail: String
    let qr: String
    let telegram_permission: Bool
    let whatsapp_permission: Bool
    let phone_permission: Bool

}
