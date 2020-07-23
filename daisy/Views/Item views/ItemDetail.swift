//
//  ItemDetail.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemDetail: View {
    @State var showAddItem = false
    @EnvironmentObject var itemViewModel: ItemsViewModel
    
    let list: UserList
    var item: Item
    var reserveButton: some View {
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
    
    var takeButton: some View {
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
    
    var seeButton: some View {
        Button(action: {
            print("See")
        }) {
            HStack{
                Text(item.url ?? "")
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.dPrimaryButton)
                    .cornerRadius(15.0)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { self.showAddItem = true }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.dDarkBlueColor)
                    Text("Edit")
                }.foregroundColor(.dDarkBlueColor)
            }
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
        .modifier(DismissingKeyboardOnSwipe())
    }
}

#if DEBUG
struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemDetail(list: staticList, item: staticTakenItem)
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
