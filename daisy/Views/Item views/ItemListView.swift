//
//  ItemListView.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemListView: View {
    @ObservedObject var itemViewModel: ItemsViewModel
    @State private var showSortSheet = false
    @State private var itemRowsDisplayMode: ItemsViewModel.DisplayMode = .compact
    
    var list: UserList
    
    var currentItems: [Item] = [staticItem,
                                staticTakenItem,
                                staticReservedItem,
                                Item(id: "2001",
                                     listID: "1",
                                     createdAt: Date(),
                                     updatedAt: Date(),
                                     title: "My static Item with long and long title",
                                     image: "turtlerock",
                                     url: "http://ugalek.com",
                                     price: 10,
                                     description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                     status: 1),
                                Item(id: "2002",
                                     listID: "1",
                                     createdAt: Date(),
                                     updatedAt: Date(),
                                     title: "My static Item with long and long title",
                                     image: "turtlerock",
                                     url: "http://ugalek.com",
                                     price: 10,
                                     description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                     status: 1),
                                Item(id: "2003",
                                     listID: "1",
                                     createdAt: Date(),
                                     updatedAt: Date(),
                                     title: "My static Item with long and long title",
                                     image: "turtlerock",
                                     url: "http://ugalek.com",
                                     price: 10,
                                     description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                     status: 1),
                                Item(id: "2004",
                                     listID: "1",
                                     createdAt: Date(),
                                     updatedAt: Date(),
                                     title: "My static Item with long and long title",
                                     image: "turtlerock",
                                     url: "http://ugalek.com",
                                     price: 10,
                                     description: "Mi, tellus fermentum class. Molestie id eget sem neque et condimentum pharetra penatibus luctus morbi et parturient. Purus imperdiet libero penatibus vivamus est lacinia montes nam tincidunt convallis? Maecenas nec placerat gravida bibendum ultricies nisi, lobortis lacinia. Venenatis ad leo potenti vel, molestie elementum. Penatibus purus cras auctor dolor etiam natoque tristique bibendum magnis. Viverra natoque. Eros hac quis tempor dolor mi. Morbi porttitor sit natoque enim facilisi! Cursus, elementum gravida metus luctus auctor justo. Nostra vel aptent vel risus iaculis felis consectetur bibendum duis. Tellus in tellus neque tristique eget cubilia ultricies nostra. Mattis nascetur pharetra imperdiet. Placerat dapibus sapien himenaeos ultrices, euismod dui mattis eros lorem. Natoque tempus in parturient. Leo at quis facilisi dapibus convallis primis est ultrices sit?",
                                     status: 1)]
//    var currentItems: [Item] {
//        get {
//            if !itemViewModel.searchText.isEmpty {
//                return itemViewModel.searchResults
//            } else if itemViewModel.sort != nil {
//                return itemViewModel.sortedItems
//            } else {
//                return itemViewModel.items
//            }
//        }
//    }
    
    @State var showAddItem = false
    private var addButton: some View {
        Button(action: { self.showAddItem.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(label: Text("Add new"))
                .padding()
        }
    }
    
    private var sortButton: some View {
        Button(action: {
            self.showSortSheet.toggle()
        }) {
            Image(systemName: itemViewModel.sort == nil ? "arrow.up.arrow.down.circle" : "arrow.up.arrow.down.circle.fill")
                .imageScale(.large)
        }
    }
    
    private var layoutButton: some View {
        Button(action: {
            self.itemRowsDisplayMode = self.itemRowsDisplayMode == .compact ? .large : .compact
        }) {
            Image(systemName: itemRowsDisplayMode == .large ? "list.dash" : "rectangle.grid.1x2")
                .imageScale(.large)
        }
    }
    
    private var sortSheet: ActionSheet {
        var buttons: [ActionSheet.Button] = []
        for sort in ItemsViewModel.Sort.allCases {
            buttons.append(.default(Text(LocalizedStringKey(sort.rawValue.localizedCapitalized)),
                                    action: {
                                        self.itemViewModel.sort = sort
            }))
        }
        
        if itemViewModel.sort != nil {
            buttons.append(.default(Text("Clear Selection"), action: {
                self.itemViewModel.sort = nil
            }))
        }
        
        buttons.append(.cancel())
        
        let title = Text("Sort items")
        
        if let currentSort = itemViewModel.sort {
            let currentSortName = NSLocalizedString(currentSort.rawValue.localizedCapitalized, comment: "")
            return ActionSheet(title: title,
                               message: Text("Current Sort: \(currentSortName)"),
                               buttons: buttons)
        }
        
        return ActionSheet(title: title, buttons: buttons)
    }
    
    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: 10)
    ]
    
    private var compactView: some View {
        ForEach(currentItems) { item in
            NavigationLink(destination: ItemDetail(item: item)) {
                ItemRow(item: item)
            }
        }
        .listRowBackground(Color.dBackground)
    }
    
    private var largeView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(currentItems, id: \.self) { item in
                    VStack {
                        Image(item.image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                            .overlay(PriceOverlay(item: item))
                        HStack {
                            if item.status == 2 {
                                // reserved
                                Image(systemName: "gift")
                                    .imageScale(.medium)
                                    .foregroundColor(Color.dSecondaryButton)
                            } else if item.status == 3 {
                                // taken
                                Image(systemName: "gift.fill")
                                    .imageScale(.medium)
                                    .foregroundColor(.gray)
                            }
                            Text(item.title)
                                .font(.footnote)
                                .lineLimit(1)
                        }
                    }
                } // ForEach
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        List {
            Section(header: SearchField(searchText: $itemViewModel.searchText,
                                        placeholder: "Search a item"))
            {
                switch self.itemRowsDisplayMode {
                case .compact: compactView
                case .large: largeView
                }
            }
        }
        .id(itemViewModel.sort)
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(itemViewModel.list.title), displayMode: .automatic)
        .navigationBarItems(trailing: HStack(spacing: 12) {
            addButton
            sortButton
            layoutButton
        })
        .modifier(DismissingKeyboardOnSwipe())
        .actionSheet(isPresented: $showSortSheet, content: { self.sortSheet })
        .sheet(isPresented: $showAddItem) {
            ItemEdit(
                itemViewModel: self.itemViewModel,
                showAddItem: self.$showAddItem,
                list: self.list
            )
        }
    }
}

#if DEBUG
struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemListView(itemViewModel: ItemsViewModel(list: staticList), list: staticList)
        }
    }
}
#endif
