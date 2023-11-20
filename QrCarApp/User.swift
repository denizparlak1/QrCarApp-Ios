//
//  User.swift
//  QrCarApp
//
//  Created by Deniz Parlak on 23.03.2023.
//

import Foundation

struct UserData: Decodable {
    let userId: String
    let plate: String
    let phone: String
    let message: String
    let photo: String
    let mail: String
    let whatsapp_permission: Bool
    let telegram_permission: Bool
    let sms_permission: Bool
    let name_permission: Bool
    let phone_permission: Bool
    let qr: String
    let first_login: Bool
    let fullname: String
}
