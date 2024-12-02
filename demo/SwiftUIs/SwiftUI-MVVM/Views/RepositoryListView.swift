//
//  RepositoryListView.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import SwiftUI

struct RepositoryListView: View {
    
    @ObservedObject var viewModel: RepositoryListViewModel
    
    var body: some View {
        
        NavigationView {
            
            List(viewModel.repositories) { repository in
                RepositoryListRow(repository: repository)
            }
            .alert(isPresented: $viewModel.isErrorShown, content: { () -> Alert in
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage))
            })
            .navigationBarTitle(Text("SwiftUI"))
        }
        .onAppear(perform: { self.viewModel.apply(.onAppear) })
    }
}

#if DEBUG
struct RepositoryListView_Previews : PreviewProvider {
    static var previews: some View {
        RepositoryListView(viewModel: .init())
    }
}
#endif
