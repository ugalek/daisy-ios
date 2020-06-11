//
//  ItemsViewModel.swift
//  daisy
//
//  Created by Galina on 28/05/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

class ItemsViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var sortedItems: [Item] = []
    @Published var searchItems: [Item] = []
    @Published var searchText = ""
    
    public let list: UserList
    
    private var searchCancellable: AnyCancellable?
    
    enum Sort: String, CaseIterable {
        case title, price, status
    }
    
    var sort: Sort? {
        didSet {
            guard let sort = sort else { return }
            switch sort {
            case .title:
                let order: ComparisonResult = sort == oldValue ? .orderedAscending : .orderedDescending
                sortedItems = items.sorted{ $0.title.localizedCompare($1.title) == order }
            case .price:
                let compare: (Float64, Float64) -> Bool = sort == oldValue ? (<) : (>)
                sortedItems = items.filter{ $0.price != nil}.sorted{ compare($0.price!, $1.price!) }
            case .status:
                let compare: (uint, uint) -> Bool = sort == oldValue ? (<) : (>)
                sortedItems = items.sorted{ compare($0.status, $1.status) }
            }
        }
    }
    
    public init(list: UserList) {
        self.list = list

        searchCancellable = $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .map(items(with:))
            .sink{ [weak self] in
                self?.searchItems = $0
        }
        
        NetworkManager().genericFetch(urlString: "lists/\(list.id)/items") { (i: ItemResults) in
            self.items = i.items
        }
    }
    
    private func items(with string: String) -> [Item] {
        items.filter {
            $0.title.lowercased().contains(string.lowercased())
        }
    }
}
