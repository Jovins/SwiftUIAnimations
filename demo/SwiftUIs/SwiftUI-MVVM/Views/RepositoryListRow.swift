//
//  RepositoryListRow.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import SwiftUI

struct RepositoryListRow: View {
    
    @State private var remoteImage: UIImage? = nil
    let placeHolder = UIImage(named: "profilepic")
    @State var repository: Repository
    
    var body: some View {
        
        NavigationLink(destination: RepositoryDetailView(viewModel: .init(repository: repository))) {
            HStack {
                Image(uiImage: self.remoteImage ?? self.placeHolder!)
                    .resizable()
                    .frame(width: 42, height: 42, alignment: .leading)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .cornerRadius(8.0)
                    .onAppear(perform: fetchRemoteImage)
                Text(repository.fullName)
            }
            
        }
    }
    
    func fetchRemoteImage() {
        
        URLSession.shared.dataTask(with: repository.owner.avatarUrl) { (data, response, error) in
            
            if let da = data, let image = UIImage(data: da) {
                self.remoteImage = image
            }
            else{
                print(error ?? "")
            }
        }.resume()
    }
}

#if DEBUG
struct RepositoryListRow_Previews : PreviewProvider {
    static var previews: some View {
        RepositoryListRow(repository:
            Repository(
                id: 1,
                fullName: "foo",
                owner: User(id: 1, login: "bar", avatarUrl: URL(string: "baz")!)
            )
        )
    }
}
#endif
