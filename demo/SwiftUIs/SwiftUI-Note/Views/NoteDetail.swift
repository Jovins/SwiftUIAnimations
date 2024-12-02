//
//  NoteDetail.swift
//  SwiftUI-Note
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct NoteDetail: View {
    
    @EnvironmentObject var userData: UserData
    var note: Note
    private var text: State<String>
    
    init(note: Note) {
        self.note = note
        self.text = .init(initialValue: note.text)
    }
    
    var noteIndex: Int {
        userData.notes.firstIndex(where: { $0.id == note.id }) ?? 0
    }
    
    var body: some View {
        VStack {
            TextField("", text: self.text.projectedValue,
                      onEditingChanged: { _ in
                        self.updateNote()
                        
                      },
                      onCommit: {})
            Spacer()
        }
        .padding()
        .navigationBarTitle(Text(NoteData.dateToString(date: note.date)), displayMode: .inline)
    }
    
    private func updateNote() {
        self.userData.notes[self.noteIndex].text = self.text.wrappedValue
    }
}

#if DEBUG
struct NoteDetail_Previews : PreviewProvider {
    static var previews: some View {
        NoteDetail(note: NoteData.shared.notes[0])
            .environmentObject(UserData())
    }
}
#endif
