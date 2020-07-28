//
//  ItemDetail.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemDetail: View {
    @EnvironmentObject var itemViewModel: ItemsViewModel
    @Binding var isPresented: Bool
    
    let list: UserList
    var item: Item
    
    private var reserveButton: some View {
        Button(action: {
            print("reserve")
        }) {
            HStack{
                Text("Reserve")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dSecondaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
    
    private var takeButton: some View {
        Button(action: {
            print("taken")
        }) {
            HStack{
                Text("Take it!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dPrimaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
    
    @State var showingDeleteAlert = false
    private var trashButton: some View {
        Button(action: { self.showingDeleteAlert = true }) {
            HStack{
                Image(systemName: "trash")
                    .imageScale(.large)
                    .accessibility(label: Text("Delete item"))
            }
        }
    }

    @State var showAddItem = false
    private var editButton: some View {
        Button(action: { self.showAddItem = true }) {
            HStack{
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
                    .accessibility(label: Text("Edit item"))
                Text("Edit")
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.dBackground.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    ItemImage(item: item, imageSize: ImageSize.itemDetail)
                    Spacer()
                }
                ItemPrice(item: item)
                Divider()
                Text(item.title)
                    .font(.title)
                HStack(spacing: 2) {
                    Image(systemName: "link")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    Link(item.url ?? "/", destination: URL(string: item.url ?? "/")!)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .foregroundColor(.dDarkBlueColor)
                ScrollView {
                    Text(item.description ?? "")
                        .font(.subheadline)
                }
                Spacer()
            }
            .padding()
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(trailing:
                                HStack(spacing: 15){
                                    editButton
                                    trashButton
                                }.foregroundColor(.dDarkBlueColor))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing: 2) {
                    Button(action: { print("reserve") }) {
                        Image(systemName: "hourglass")
                            .foregroundColor(.dDarkBlueColor)
                        Text("Reserve")
                    }
                    Spacer()
                    Button(action: { print("Take it") }) {
                        Image(systemName: "cart.badge.plus")
                            .foregroundColor(.dDarkBlueColor)
                        Text("Buy")
                    }
                }
                .foregroundColor(.dDarkBlueColor)
            }
        }
        .sheet(isPresented: $showAddItem) {
            ItemEdit(
                itemViewModel: itemViewModel,
                showAddItem: $showAddItem,
                list: list,
                item: item,
                editMode: true
            )
        }
        .alert(isPresented: self.$showingDeleteAlert) {
            Alert(title: Text("Delete item"),
                  message: Text("Are you sure?"),
                  primaryButton: .destructive(Text("Delete")) {
                deleteItem()
            }, secondaryButton: .cancel())}
        .modifier(DismissingKeyboardOnSwipe())
    }
    
    func deleteItem() {
        itemViewModel.deleteItemByID(
            listID: list.id,
            itemID: item.id,
            imageID: item.imageID)
        self.isPresented = false
    }
}

#if DEBUG
struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemDetail(isPresented: .constant(true), list: staticList, item: staticTakenItem)
            }
            .environment(\.colorScheme, .light)
            
//            NavigationView {
//                ItemDetail(list: staticList, item: staticTakenItem)
//            }
//            .environment(\.colorScheme, .dark)
        }
    }
}
#endif
