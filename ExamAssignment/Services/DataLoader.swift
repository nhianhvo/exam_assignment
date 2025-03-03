//
//  DataLoader.swift
//  ExamAssignment
//
//  Created by Anh Vo on 3/3/25.
//

import Foundation

class DataLoader {
    static func loadJSON<T: Decodable>(_ filename: String) -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Don't load file JSON: \(filename)")
        }
        
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(filename): \(String(describing: try? JSONSerialization.jsonObject(with: data)))")
        }
        return loaded
    }
}
