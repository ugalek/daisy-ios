//
//  ItemEdit.swift
//  daisy
//
//  Created by Galina on 27/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Combine
import SwiftUI

class ItemFields: ObservableObject, Codable {
    enum CodingKeys: String, CodingKey {
        case title, image
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var title: String = "" {
        didSet {
            self.titleIsValid = Validators.titleIsValid(title: self.title)
            update()
        }
    }
    var image: String = "turtlerock" { didSet { update() } }
    var url: String = "http://ugalek.com" { didSet { update() } }
    var price: String = "" { didSet { update() } }
    var description: String = "Description" { didSet { update() } }
    var titleIsValid: Bool = true { didSet { update() } }
    
    var isValid: Bool {
        if title.isEmpty || url.isEmpty || !titleIsValid {
            return false
        }
        return true
    }
    
    func update() {
        objectWillChange.send(())
    }
}

struct ItemEdit: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var itemViewModel: ItemsViewModel
    @ObservedObject var itemFields = ItemFields()

    @Binding var showAddItem: Bool
    
    let list: UserList
    
    private var doneButton: some View {
        Button(action: { self.doneAction() }) {
            Text("Done").bold()
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.showAddItem = false
            self.presentationMode.wrappedValue.dismiss()
        })
        { Text("Cancel") }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Text(list.title)
                VStack(alignment: .leading) {
                    TextField("Title", text: $itemFields.title)
                        .font(.caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .overlay(NotValidImage(isValid: self.itemFields.titleIsValid), alignment: .trailing)
                    if !self.itemFields.titleIsValid {
                        Text("Title is not valid")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }

                TextField("Image", text: $itemFields.image)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("URL (http://example.com)", text: $itemFields.url)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Price", text: $itemFields.price)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Description", text: $itemFields.description)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } // Form
            .navigationBarTitle(Text("Add new Item"), displayMode: .inline)
            .navigationBarItems(leading: cancelButton,
                                trailing: doneButton
                                    .disabled(!itemFields.isValid)
            )
        }
    }
    
    func doneAction() {
        self.itemViewModel.addItem(
            listID: self.list.id,
            title: self.itemFields.title,
            image: self.itemFields.image,
            url: self.itemFields.url,
            price: self.itemFields.price,
            description: self.itemFields.description)
        self.showAddItem = false
    }
}

#if DEBUG
struct ItemEdit_Previews: PreviewProvider {
    static var previews: some View {
        ItemEdit(
            itemViewModel: ItemsViewModel(list: staticList),
            showAddItem: .constant(false),
            list: staticList)
    }
}
#endif

struct NotValidImage: View {
    var isValid: Bool
    
    var body: some View {
        HStack {
            if !isValid {
                Image(systemName: "exclamationmark.shield")
                    .foregroundColor(.red)
                    .padding()
            } else {
                EmptyView()
            }
        }
    }
}
