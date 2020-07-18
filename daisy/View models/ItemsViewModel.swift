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
    @Published var searchResults: [Item] = []
    @Published var searchText = ""
    
    public let list: UserList
    
    // used to store `AnyCancellable`, without keeping this reference alive, the network publisher will terminate immediately
    private var searchCancellable: AnyCancellable?
    private var disposables = Set<AnyCancellable>()
    
    enum Sort: String, CaseIterable {
        case title, price, status
    }
    enum DisplayMode {
        case compact, large
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
                self?.searchResults = $0
        }
        
        if items.isEmpty {
            fetchData()
        }
    }
    
    private func fetchData() {
        DaisyService.shared.searchItems(listID: list.id) { response in
            if response.isSuccess {
                if let responseItems = response.model {
                    self.items = responseItems
                }
            }
        }
    }
    
    private func items(with string: String) -> [Item] {
        items.filter {
            $0.title.lowercased().contains(string.lowercased())
        }
    }
    
    func addItem(listID: String, title: String, imageID: String?, url: String, price: Float64, description: String) {
        var body: [String: Any?] = [
            "title": title,
            "image_id": nil,
            "url": url,
            "price": price,
            "description": description,
            "status": 1]
        
        if let image = imageID {
            body.updateValue(image, forKey: "image_id")
        }
        
        DaisyService.shared.postRequest(endpoint: .items(listID: listID), body: body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                    self.items.append($0)
                })
            .store(in: &disposables)
    }
    
    func deleteItem(listID: String, at index: Int) {
        DaisyService.shared.deleteRequest(endpoint: .item(listID: listID, id: items[index].id)) { result in
            if result {
                self.items.remove(at: index)
            }
        }
    }
}
