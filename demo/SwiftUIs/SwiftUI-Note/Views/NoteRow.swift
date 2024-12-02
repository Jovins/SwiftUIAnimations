//
//  NoteRow.swift
//  SwiftUI-Note
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct NoteRow: View {
    
    var note: Note
    
    var body: some View {
        HStack {
            Text(note.text)
        }
    }
}

#if DEBUG
struct NoteRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            NoteRow(note: Note(text: "New Note"))
            NoteRow(note: Note(text: "Another Note"))
        }
        .previewLayout(.fixed(width: 300, height: 50))
    }
}
#endif
