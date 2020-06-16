//
//  ItemEdit.swift
//  daisy
//
//  Created by Galina on 27/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ItemEdit: View {
    @ObservedObject var itemViewModel: ItemsViewModel
    @Binding var showAddItem: Bool
    
    @State var title: String = ""
    @State var image: String = "turtlerock"
    @State var url: String = "http://ugalek.com"
    @State var price: String = "5"
    @State var description: String = "Description"
    let list: UserList
    
    var body: some View {
        NavigationView {
            VStack {
                Text(list.title)
                HStack(alignment: .center) {
                    Text("Title")
                        .font(.callout)
                    TextField("", text: $title)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(alignment: .center) {
                    Text("Image")
                        .font(.callout)
                    TextField("", text: $image)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(alignment: .center) {
                    Text("URL")
                        .font(.callout)
                    TextField("", text: $url)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(alignment: .center) {
                    Text("Price")
                        .font(.callout)
                    TextField("", text: $price)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(alignment: .center) {
                    Text("Description")
                        .font(.callout)
                    TextField("", text: $description)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Spacer()
            }
            .padding()
            .navigationBarTitle(Text("Sheet View"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
               self.itemViewModel.addItem(
                    listID: self.list.id,
                    title: self.title,
                    image: self.image,
                    url: self.url,
                    price: self.price,
                    description: self.description)
                self.showAddItem = false
            }) {
                Text("Done").bold()
            })
        }
    }
}
