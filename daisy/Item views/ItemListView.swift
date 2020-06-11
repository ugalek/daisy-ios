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
    @State private var itemRowsDisplayMode: ItemRow.DisplayMode = .compact
    
    var list: UserList
        
    var currentItems: [Item] {
        get {
            if !itemViewModel.searchText.isEmpty {
                return itemViewModel.searchItems
            } else if itemViewModel.sort != nil {
                return itemViewModel.sortedItems
            } else {
                return itemViewModel.items
            }
        }
    }
    
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
            Image(systemName: itemRowsDisplayMode == .large ? "rectangle.grid.1x2" : "list.dash")
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
    
    var body: some View {
        List {
            Section(header: SearchField(searchText: $itemViewModel.searchText)) {
                ForEach(currentItems) { item in
                    NavigationLink(destination: ItemDetail(item: item)) {
                        ItemRow(displayMode: self.itemRowsDisplayMode, item: item)
                            //  .environmentObject(ItemDetailViewModel(item: item))
                            .listRowBackground(Color.red)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .id(itemViewModel.sort)
        .modifier(DismissingKeyboardOnSwipe())
        .navigationBarTitle(Text(itemViewModel.list.title),
                            displayMode: .automatic)
            .navigationBarItems(trailing:
                HStack(spacing: 12) {
                    addButton
                    sortButton
                    layoutButton
            })
            .actionSheet(isPresented: $showSortSheet, content: { self.sortSheet })
            .sheet(isPresented: $showAddItem) {
                ItemEdit(
                    showAddItem: self.$showAddItem,
                    list: self.list
                )
        }
    }    
}

// From https://stackoverflow.com/questions/56491386/how-to-hide-keyboard-when-using-swiftui
struct DismissingKeyboardOnSwipe: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        return content
        #else
        return content.gesture(swipeGesture)
        #endif
    }
    
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged(endEditing)
    }
    
    private func endEditing(_ gesture: DragGesture.Value) {
        UIApplication.shared.connectedScenes
            .filter {$0.activationState == .foregroundActive}
            .map {$0 as? UIWindowScene}
            .compactMap({$0})
            .first?.windows
            .filter {$0.isKeyWindow}
            .first?.endEditing(true)
    }
}

