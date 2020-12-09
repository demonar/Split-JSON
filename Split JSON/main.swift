//
//  main.swift
//  Split JSON
//
//  Created by Alejandro Moya on 07/12/2020.
//

import Foundation

let dispatchGroup = DispatchGroup()
let parser = ParseJsonAndUpload()


func run() {
    dispatchGroup.enter()
    let args = CommandLine.arguments
    parser.params = Params(filePath: args[1], limit: Int(args[2]) ?? 20,
                           method: args[3], url: args[4], finish: {
        dispatchGroup.leave()
    })
    
    print("Starting...")
    parser.start()
    dispatchGroup.notify(queue: DispatchQueue.main) {
        exit(EXIT_SUCCESS)
    }
    dispatchMain()
}

run()
