//
//  UpdateList.swift
//  SwiftUI-DesignCode
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct UpdateList: View {
    
    var updates = updateData
    @ObservedObject var store = UpdateStore(updates: updateData)
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(self.store.updates) { item in
                    
                    NavigationLink(destination: UpdateDetail(title: item.title, text: item.text, image: item.image)) {
                        
                        HStack(spacing: 12.0) {
                            
                            Image(item.image)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 80, height: 80)
                               .background(Color("background"))
                               .cornerRadius(20)

                            VStack(alignment: .leading) {
                                
                               Text(item.title)
                                  .font(.headline)
                               Text(item.text)
                                  .lineLimit(2)
                                  .lineSpacing(4)
                                  .font(.subheadline)
                                  .frame(height: 50.0)
                               Text(item.date)
                                  .font(.caption)
                                  .fontWeight(.bold)
                                  .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 8.0)
                }
                .onDelete{ index in
                    guard let i = index.first else { return }
                    self.store.updates.remove(at: i)
                }
                .onMove(perform: move)
            }
            .navigationBarTitle(Text("Updates"))
            .navigationBarItems(leading: Button(action: addUpdate, label: {
                Text("Add Update")
            }), trailing: EditButton())
        }
    }
    
    func addUpdate() {
        store.updates.append(Update(image: "Certificate1", title: "New Title", text: "New Text", date: "JUL 1"))
    }
    
    func move(from source: IndexSet, to destination: Int) {
        guard let index = source.first else { return }
       store.updates.swapAt(index, destination)
    }
}

#if DEBUG
struct UpdateList_Previews: PreviewProvider {
   static var previews: some View {
      UpdateList()
   }
}
#endif
