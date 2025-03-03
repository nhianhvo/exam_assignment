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
        return try! JSONDecoder().decode(T.self, from: data)
    }
}
