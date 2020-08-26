//
//  ItemListView.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

enum ActiveItemsViewSheet {
    case list, item
}

struct ItemListView: View {
    @ObservedObject var listViewModel: ListViewModel
    @ObservedObject var itemViewModel: ItemsViewModel
    
    @State private var showSortSheet = false
    @State private var itemRowsDisplayMode: ItemsViewModel.DisplayMode = .compact
    
    @State var showDetailView = false
    @State private var showSheet = false
    @State private var activeSheet: ActiveItemsViewSheet = .item
    
    var list: UserList
    
    var currentList: UserList {
        get {
            if listViewModel.addedlist != nil {
                return listViewModel.addedlist ?? list
            } else {
                return list
            }
        }
    }

    var currentItems: [Item] {
        get {
            if !itemViewModel.searchText.isEmpty {
                return itemViewModel.searchResults
            } else if itemViewModel.sort != nil {
                return itemViewModel.sortedItems
            } else {
                return itemViewModel.items
            }
        }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 130), spacing: 10)
    ]
    
    private var addButton: some View {
        Button(action: {
            self.showSheet.toggle()
            self.activeSheet = .item
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(label: Text("Add new"))
        }
    }
    
    private var editButton: some View {
        Button(action: {
            self.showSheet.toggle()
            self.activeSheet = .list
        }) {
            Image(systemName: "pencil")
                .imageScale(.large)
                .accessibility(label: Text("Edit list"))
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
        .navigationBarTitle(Text(currentList.title), displayMode: .automatic)
        .navigationBarItems(trailing:
                                HStack(spacing: 15){
                                    addButton
                                    editButton
                                    sortButton
                                    layoutButton
                                }.foregroundColor(.dDarkBlueColor))
        .modifier(DismissingKeyboardOnSwipe())
        .actionSheet(isPresented: $showSortSheet, content: { self.sortSheet })
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .item {
                ItemEdit(
                    itemViewModel: self.itemViewModel,
                    showAddItem: self.$showSheet,
                    list: self.list,
                    editMode: false
                )
            } else {
                ListEdit(listViewModel: self.listViewModel,
                         showAddList: self.$showSheet,
                         list: self.list,
                         editMode: true)
            }
            
        }
    }
}

extension ItemListView {
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
    
    private var compactView: some View {
        ForEach(currentItems) { item in
            NavigationLink(destination: ItemDetail(isPresented: $showDetailView, list: list, item: item)
                            .environmentObject(itemViewModel)) {
                ItemRow(item: item)
            }
        }
        .onDelete(perform: deleteItems)
        .listRowBackground(Color.dBackground)
    }
    
    private var largeView: some View {   
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(currentItems, id: \.self) { item in
                    NavigationLink(destination: ItemDetail(isPresented: $showDetailView, list: list, item: item)
                                    .environmentObject(itemViewModel)) {
                        ItemLargeView(item: item)
                    }
                } // ForEach
            }
        }
        .padding(.horizontal)
        .listRowBackground(Color.dBackground)
    }
    
    func deleteItems(at offsets: IndexSet) {
        if let first = offsets.first {
            itemViewModel.deleteItem(listID: list.id, at: first)
        }
    }
}

#if DEBUG
struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemListView(listViewModel: ListViewModel(), itemViewModel: ItemsViewModel(list: staticList), list: staticList)
            }
            .environment(\.colorScheme, .light)
        }
    }
}
#endif
