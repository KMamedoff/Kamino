//
//  Services.swift
//  Kamino
//
//  Created by Kenan Mamedoff on 02/04/2019.
//  Copyright © 2019 Kenan Mamedoff. All rights reserved.
//

import Foundation

struct Service {
    static let shared = Service()
    
    func getRequest<T: Decodable>(urlString: String, completion: @escaping (T) -> ()) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, err) in
            if let err = err {
                print("Failed to fetch:", err)
                return
            }
            
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let homeFeed = try decoder.decode(T.self, from: data)
                
                DispatchQueue.main.async {
                    completion(homeFeed)
                }
            } catch let jsonErr {
                print("Failed to serialize JSON:", jsonErr)
            }
            
            }.resume()
    }
    
    func postRequest<T: Decodable>(urlString: String, body: String, value: [[String]], completion: @escaping (T) -> ()) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        value.forEach { request.addValue($0[0], forHTTPHeaderField: $0[1]) }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = response {
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    
                    let feed = try decoder.decode(T.self, from: data)

                    DispatchQueue.main.async {
                        completion(feed)
                    }
                } catch let jsonErr {
                    print("Failed to serialize JSON:", jsonErr)
                }
            } else {
                print(error ?? "Unknown error")
            }
        }.resume()
    }
}
