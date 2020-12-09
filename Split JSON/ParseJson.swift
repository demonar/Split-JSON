//
//  ParseJson.swift
//  Split JSON
//
//  Created by Alejandro Moya on 07/12/2020.
//

import Foundation
import SwiftyJSON

class ParseJsonAndUpload {
    
    var params: Params?
    var iterator: Dictionary<String, JSON>.Iterator?
    
    func start() {
        guard let params = params else { return }
        let fileUrl = URL(fileURLWithPath: params.filePath)
        do {
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            if let json = try? JSON(data: data, options: .allowFragments).dictionary, json.count > 0 {
                print("Processing \(json.count) items\n")
                iterator = json.makeIterator()
                process()
            }
        } catch {
            print("Error parsing data")
        }
    }
    
    func process() {
        guard let params = params else { return }
        var slice = JSON([:])
        for _ in 0..<params.limit {
            if let obj = iterator?.next() {
                slice[obj.key].object = obj.value.object
            }
        }
        guard let data = try? slice.rawData() else {
            print("Error creating json data")
            return
        }
        print("Sending \(slice.count) items")
        send(data: data) { [weak self] success in
            guard let this = self else { return }
            if !success || slice.count != params.limit {
                params.finish()
                return
            }
            this.process()
        }
    }
    
    func send(data: Data, completion: @escaping (Bool) -> Void) {
        guard let params = params, let url = URL(string: params.url) else { return }
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = params.method.uppercased()
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        print("Sending request...")
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            let result = error == nil ? "success" : "error: \(error?.localizedDescription ?? "unknown")"
            print("Completed request with \(result)\n")
            completion(error == nil)
        })
        task.resume()
    }
}
