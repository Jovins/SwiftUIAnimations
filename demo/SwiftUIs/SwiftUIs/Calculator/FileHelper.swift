//
//  FileHelper.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/28.
//

import Foundation

enum FileHelper {
    
    static func loadBundledJSON<T: Decodable>(file: String) -> T {
        
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            fatalError("Resource not found: \(file)")
        }
        return try! loadJSON(from: url)
    }
    
    static func loadJSON<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try appDecoder.decode(T.self, from: data)
    }
    
    static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try appEncoder.encode(value)
        try data.write(to: url)
    }
    
    static func writeJSON<T: Encodable>(
        _ value: T,
        to directory: FileManager.SearchPathDirectory,
        fileName: String
    ) throws {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        try writeJSON(value, to: url.appendingPathComponent(fileName))
    }
    
    static func delete(
        from directory: FileManager.SearchPathDirectory,
        fileName: String) throws {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        try FileManager.default.removeItem(at: url.appendingPathComponent(fileName))
    }
}
