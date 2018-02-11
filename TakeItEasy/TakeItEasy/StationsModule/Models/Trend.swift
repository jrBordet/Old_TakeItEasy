//
//  Trend.swift
//  TakeItEasy
//
//  Created by Jean Raphael on 09/02/2018.
//  Copyright © 2018 Jean Raphael Bordet. All rights reserved.
//

import Foundation

struct Trend: Decodable {
    let origine: String
    let destinazione: String
    let compNumeroTreno: String
    let compOraUltimoRilevamento: String
    let compRitardoAndamento: [String]
}
