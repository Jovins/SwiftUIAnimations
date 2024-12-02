//
//  Setting.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct Settings: View {
    
    @State var receive: Bool = false
    @State var number: Int = 1
    @State var selection: Int = 1
    @State var date: Date = Date()
    @State var email: String = "jovinscoder@gmail.com"
    @State var submit: Bool = false
    
    var body: some View {
        
        NavigationView {
           Form {
              Toggle(isOn: $receive) {
                 Text("Recieve Notifications")
              }
              Stepper(value: $number, in: 1...10) {
                 Text("\(number) Notification\(number > 1 ? "s" : "") per week")
              }
              Picker(selection: $selection, label: Text("Favourite course")) {
                 Text("SwiftUI").tag(1)
                 Text("React").tag(2)
              }
              DatePicker(selection: $date, label: {
                 Text("Date")
              })
              Section(header: Text("Email")) {
                 TextField("Your email: ", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
              }
              Button(action: { self.submit.toggle() }) {
                 Text("Submit")
              }
              .alert(isPresented: $submit, content: {
                 Alert(title: Text("Thanks"), message: Text("Email: \(email)"))
              })
           }
           .navigationBarTitle("Settings")
        }
    }
}

#if DEBUG
struct Settings_Previews: PreviewProvider {
   static var previews: some View {
      Settings()
   }
}
#endif
