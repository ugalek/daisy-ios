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
    @Published var addedlist: UserList?
    @Published var searchResults: [UserList] = []
    @Published var searchText = ""
    @Published var errorMessage = ""
    
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
        DaisyService.shared.searchList { response in
            if response.isSuccess {
                if let responseLists = response.model {
                    self.lists = responseLists
                }
            }
        }
    }
    
    private func lists(with string: String) -> [UserList] {
        lists.filter {
            $0.title.lowercased().contains(string.lowercased())
        }
    }
    
    func addList(title: String, imageID: String?, surprise: Bool) {
        var body: [String: Any?] = [
        //    "user_id": "1",
            "title": title,
            "surprise": surprise,
            "image_id": nil
        ]
        
        if let image = imageID {
            body.updateValue(image, forKey: "image_id")
        }
        
        DaisyService.shared.postRequest(endpoint: .lists, body: body)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: {
                    self.lists.append($0)
                })
            .store(in: &disposables)
    }
    
    func editList(oldList: UserList, title: String, imageID: String?, surprise: Bool, completion: @escaping(Bool) -> ()) {
        var body: [String: Any?] = [
            "title": title,
            "image_id": nil,
            "surprise": surprise]
        
        if let image = imageID {
            body.updateValue(image, forKey: "image_id")
        }
        
        DaisyService.shared.editList(listID: oldList.id, body: body) { response in
            if response.isSuccess {
                if let responseLists = response.model {
                    if let oldImageID = oldList.imageID {
                        if oldImageID != imageID {
                            ImageViewModel().deleteImage(imageID: oldImageID)
                        }
                    }
                    if let index = self.lists.firstIndex(of: oldList) {
                        self.lists.remove(at: index)
                    }
                    self.lists.append(responseLists)
                    self.addedlist = responseLists
                    completion(false)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = response.errorMsg ?? "Something is wrong"
                    completion(true)
                }
            }
        }
    }
    
    func deleteList(at index: Int) {
        DaisyService.shared.deleteRequest(endpoint: .list(id: lists[index].id)) { result in
            if result {
                self.lists.remove(at: index)
            }
        }
    }
}
