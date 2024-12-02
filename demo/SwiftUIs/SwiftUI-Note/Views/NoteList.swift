//
//  NoteList.swift
//  SwiftUI-Note
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct NoteList: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            List(self.userData.notes) { note in
                NavigationLink(destination: NoteDetail(note: note).environmentObject(self.userData)) {
                    NoteRow(note: note)
                }
            }
            .navigationBarTitle(Text("Notes"), displayMode: .large)
            .navigationBarItems(trailing: Button(action: self.createNote, label: {
                Text("New")
            }))
        }
    }
    
    private func createNote() {
        let newNote = Note(text: "Add Note")
        self.userData.notes.insert(newNote, at: 0)
    }
}


#if DEBUG
struct NoteList_Previews : PreviewProvider {
    
    static var previews: some View {
        
        ForEach(["iPhone SE", "iPhone XS Max"], id: \.self) { deviceName in
            NoteList()
                .environmentObject(UserData())
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
#endif
