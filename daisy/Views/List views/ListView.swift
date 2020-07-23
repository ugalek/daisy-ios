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
        NavigationLink(destination: UserView().environmentObject(self.authManager)) {
           Image(systemName: "person.crop.circle")
            .imageScale(.large)
            .accessibility(label: Text("User Profile"))
        }
    }
    
    @State private var title: String = ""
    
    var addButton: some View {
        Button(action: { self.showAddList.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.large)
                .accessibility(label: Text("Add new"))
        }.popover(
            isPresented: self.$showAddList,
            arrowEdge: .bottom
        ) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Title")
                        .font(.subheadline)
                        .foregroundColor(.dDarkBlueColor)
                    Spacer()
                }
                TextField("Title", text: $title)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: { self.doneAction() }) {
                    Text("Done").bold()
                }
                Spacer()
            }
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
                            destination: ItemListView(itemViewModel: ItemsViewModel(list: list), list: list)
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
    
    func doneAction() {
        self.listViewModel.addList(
            title: self.title)
        self.showAddList = false
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
