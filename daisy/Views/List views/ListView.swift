//
//  ListView.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var authManager: HttpAuth
    @ObservedObject var listViewModel = ListViewModel()
    
    @State var showingProfile = false
    @State var loggedOut = false
    @State private var showingDeleteAlert = false
    @State var offsets: IndexSet?
    @State private var showAddList: Bool = false
    
    var profileButton: some View {
        NavigationLink(destination:
                        UserView()
                        .environmentObject(self.authManager)
                        .environmentObject(UserViewModel(userID: DaisyService.shared.userID))) {
           Image(systemName: "person.crop.circle")
            .imageScale(.large)
            .accessibility(label: Text("User Profile"))
        }
    }
    
    var addButton: some View {
        Button(action: { self.showAddList.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(label: Text("Add new"))
        }.popover(
            isPresented: self.$showAddList,
            arrowEdge: .bottom
        ) {
            ListEdit(listViewModel: listViewModel, showAddList: self.$showAddList)
        }
    }
    
    var currentLists: [UserList] {
        get {
            if !listViewModel.searchText.isEmpty {
                return listViewModel.searchResults
            } else {
                return listViewModel.lists
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: SearchField(searchText: $listViewModel.searchText,
                                            placeholder: "Search a list"))
                {
                    ForEach(currentLists) { list in
                        NavigationLink(
                            destination: ItemListView(listViewModel: listViewModel, itemViewModel: ItemsViewModel(list: list), list: list)
                        ) {
                            ListRow(list: list)
                        }
                    }
                    .onDelete(perform: deleteList)
                    .listRowBackground(Color.dBackground)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Lists", displayMode: .automatic)
            .navigationBarItems(trailing: HStack(spacing: 15) {
                addButton
                profileButton
            })
            .alert(isPresented: self.$showingDeleteAlert) {
                Alert(title: Text("Delete list"), message: Text("Delete list and all items inside?"), primaryButton: .destructive(Text("Delete")) {
                    if let first = self.offsets?.first {
                        listViewModel.deleteList(at: first)
                    }
                }, secondaryButton: .cancel())}
            .modifier(DismissingKeyboardOnSwipe())
        }
    }
    
    func deleteList(at offsets: IndexSet) {
        self.showingDeleteAlert = true
        self.offsets = offsets
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListView()
                .environmentObject(HttpAuth())
                .environment(\.colorScheme, .dark)
            ListView()
                .environmentObject(HttpAuth())
                .environment(\.colorScheme, .light)
        }
    }
}
