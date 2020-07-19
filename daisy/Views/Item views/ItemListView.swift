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
    @State private var editMode: EditMode = .inactive
    
    var list: UserList
    
    var currentItems: [Item] = [staticItem,
                                staticTakenItem,
                                staticReservedItem]
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

    private var editButton: some View {
        HStack {
            if itemRowsDisplayMode == .compact {
                EditButton()
                    .modifier(makeCircle(editMode: editMode, cornerRadius: 12))
            } else {
                EmptyView()
            }
        }
    }
    
    @State var showAddItem = false
    private var addButton: some View {
        Button(action: { self.showAddItem.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(label: Text("Add new"))
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
            NavigationLink(destination: ItemDetail(list: list, item: item)
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
                    itemLargeView(item: item)
                }.onDelete(perform: deleteItems) // ForEach
            }
        }
        .padding(.horizontal)
        .listRowBackground(Color.dBackground)
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
        .navigationBarItems(trailing:
                                HStack(spacing: 15){
                                    editButton
                                    addButton
                                    sortButton
                                    layoutButton
                                }.foregroundColor(.dDarkBlueColor))
        .modifier(DismissingKeyboardOnSwipe())
        .environment(\.editMode, $editMode)
        .actionSheet(isPresented: $showSortSheet, content: { self.sortSheet })
        .sheet(isPresented: $showAddItem) {
            ItemEdit(
                itemViewModel: self.itemViewModel,
                showAddItem: self.$showAddItem,
                list: self.list
            )
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        if let first = offsets.first {
            itemViewModel.deleteItem(listID: list.id, at: first)
        }
        
    }
}

struct itemLargeView: View {
    @Environment(\.imageCache) var cache: ImageCache
    
    var item: Item
    var imageSize = DaisyService.shared.mainWidth / 2 - 40
    
    var body: some View {
        VStack {
            if let imageURL = item.image?.url {
                AsyncImage(
                    url: URL(string: imageURL)!,
                    cache: self.cache,
                    placeholder: Text("Loading ..."),
                    configuration: { $0.resizable() }
                )
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(8)
                .clipped()
                .overlay(PriceOverlay(item: item))
            } else {
                Image("NoImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(8)
                    .clipped()
                    .overlay(PriceOverlay(item: item))
            }
            HStack {
                if item.status == 2 {
                    // reserved
                    Image(systemName: "gift.fill")
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
    }
}

struct makeCircle: ViewModifier {
    var editMode: EditMode
    var cornerRadius: CGFloat = 16
    
    private var trash: some View {
        HStack {
            if editMode != .active {
                Image(systemName: "trash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(.dDarkBlueColor)
            } else {
                EmptyView()
            }
        }
    }
    
    func colorForEditMode(_ editMode: EditMode) -> Color {
        switch editMode {
        case .active:
            return .dDarkBlueColor
        case .inactive:
            return .dBackground
        default:
            return .dBackground
        }
    }

    func body(content: Content) -> some View {
        content
            .padding(.all, 6)
            .foregroundColor(colorForEditMode(editMode))
            .overlay(trash)
    }
}

#if DEBUG
struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            NavigationView {
//                ItemListView(itemViewModel: ItemsViewModel(list: staticList), list: staticList)
//            }
//            .environment(\.colorScheme, .dark)
            NavigationView {
                ItemListView(itemViewModel: ItemsViewModel(list: staticList), list: staticList)
            }
            .environment(\.colorScheme, .light)
        }
    }
}
#endif
