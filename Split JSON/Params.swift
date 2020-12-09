//
//  Params.swift
//  Split JSON
//
//  Created by Alejandro Moya on 07/12/2020.
//

import Foundation

struct Params {
    var filePath: String
    var limit: Int
    var method: String
    var url: String
    var finish: () -> Void
}
