//
//  NoteData.swift
//  SwiftUI-Note
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

class NoteData {
    
    static let shared = NoteData()
    
    var notes: [Note] = [Note(text: "New Note"), Note(text: "Another")]
    
    private init() {
        load()
    }
    
    private func load() {
        if let data = UserDefaults.standard.object(forKey: "notes") as? Data {
            self.notes = try! PropertyListDecoder().decode([Note].self, from: data)
        }
    }
    
    func save() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(notes), forKey: "notes")
        debugPrint("Save Notes")
    }
    
    static func dateToString(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
