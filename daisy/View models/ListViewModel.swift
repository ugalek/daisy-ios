//
//  ListViewModel.swift
//  daisy
//
//  Created by Galina on 17/06/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

class ListViewModel: ObservableObject {
    @Published var lists: [UserList] = []
    @Published var searchResults: [UserList] = []
    @Published var searchText = ""
    
    private var searchCancellable: AnyCancellable?
    private var disposables = Set<AnyCancellable>()

    public init() {
         searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .map(lists(with:))
            .sink{ [weak self] in
                self?.searchResults = $0
        }
        
        if lists.isEmpty {
            fetchData()
        }
    }
    
    private func fetchData() {
        DaisyService.getRequest(endpoint: .lists)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { response in
                    self.lists.append(contentsOf: response)
            })
            .store(in: &disposables)
    }
    
    private func lists(with string: String) -> [UserList] {
        lists.filter {
            $0.title.lowercased().contains(string.lowercased())
        }
    }
    
    func addList(title: String) {
        let body: [String: Any] = [
            "user_id": "1",
            "title": title]
        
        DaisyService.postRequest(endpoint: .lists, body: body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                    self.lists.append($0)
                })
            .store(in: &disposables)
    }
    
    func deleteList(at index: Int) {
        DaisyService.deleteRequest(endpoint: .list(id: lists[index].id)) { result in
            if result {
                self.lists.remove(at: index)
            }
        }
    }
}
