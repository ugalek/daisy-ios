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
    @State var reserve = false
    @State var take = false
    
    let list: UserList
    var item: Item
    
    private var reserveButton: some View {
        Button(action: { reserveItem() }) {
            Image(systemName: "hourglass")
                .foregroundColor(.dDarkBlueColor)
            Text("Reserve")
        }
    }
    
    private var takeButton: some View {
        Button(action: { takeItem() }) {
            Image(systemName: "cart.badge.plus")
                .foregroundColor(.dDarkBlueColor)
            Text("Buy")
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
                    ImageSquare(item: item, imageSize: ImageSize.itemDetail)
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
                    reserveButton
                        .disabled(reserve)
                    Spacer()
                    takeButton
                        .disabled(take)
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
    
    func reserveItem() {
        self.itemViewModel.editItem(
            oldItem: item,
            listID: self.list.id,
            title: item.title,
            imageID: item.imageID,
            url: item.url ?? "",
            price: Double(item.price ?? 0),
            description: item.description ?? "",
            status: 2) { result in
            self.reserve = result
        }
    }
    
    func takeItem() {
        self.itemViewModel.editItem(
            oldItem: item,
            listID: self.list.id,
            title: item.title,
            imageID: item.imageID,
            url: item.url ?? "",
            price: Double(item.price ?? 0),
            description: item.description ?? "",
            status: 3) { result in
            self.take = result
        }
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
        }
    }
}
#endif
