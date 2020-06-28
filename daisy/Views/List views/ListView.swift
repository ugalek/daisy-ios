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
    
    var profileButton: some View {
        NavigationLink(destination: UserView().environmentObject(self.authManager)) {
           Image(systemName: "person.crop.circle")
            .imageScale(.large)
            .accessibility(label: Text("User Profile"))
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
                    .listRowBackground(Color.dBackground)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Lists", displayMode: .automatic)
            .navigationBarItems(trailing: profileButton)
            .modifier(DismissingKeyboardOnSwipe())
        }
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
