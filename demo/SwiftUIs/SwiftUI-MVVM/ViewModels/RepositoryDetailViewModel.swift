//
//  RepositoryDetailViewModel.swift
//  SwiftUI-MVVM
//
//  Created by Jovins on 2021/7/28.
//

import Foundation
import SwiftUI
import Combine

final class RepositoryDetailViewModel: ObservableObject {
    
    let objectWillChange: AnyPublisher<RepositoryListViewModel, Never>
    let objectWillChangeSubject = PassthroughSubject<RepositoryListViewModel, Never>()
    
    let repository: Repository
    
    init(repository: Repository) {
        objectWillChange = objectWillChangeSubject.eraseToAnyPublisher()
        self.repository = repository
    }
}
