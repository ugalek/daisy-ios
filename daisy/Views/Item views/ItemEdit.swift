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
        case title
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var title: String = "" {
        didSet {
            self.titleIsValid = Validators.titleIsValid(title: self.title)
            update()
        }
    }
 //   var image: String = "turtlerock" { didSet { update() } }
    var imageF: Image? = nil { didSet { update() } }
    var url: String = "http://ugalek.com" { didSet { update() } }
    var price: String = "" { didSet {
        if let value = price.double {
            if value.fractionalDigits > 2 {
                price = oldValue
            }
        } else {
            price = oldValue
        }
        update()
    } }
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
    @ObservedObject var imageViewModel = ImageViewModel()
    @ObservedObject var itemFields = ItemFields()

    //@State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @Binding var showAddItem: Bool
    
    let list: UserList
    var item: Item?
    
    var imageID: String? {
        get {
            if imageViewModel.images.count == 0 {
                return nil
            } else {
                return imageViewModel.images[imageViewModel.images.count-1].id
            }
        }
    }
    
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
    
    private var itemForm: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.dDarkBlueColor)
                Spacer()
                if !self.itemFields.titleIsValid {
                    Text("A minimum of 3 characters")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            TextField("Title", text: $itemFields.title)
                .font(.caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(NotValidImage(isValid: self.itemFields.titleIsValid), alignment: .trailing)
            
            Text("URL")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            TextField("URL (http://example.com)", text: $itemFields.url)
                .font(.caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("Price")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            
            TextField("Price", text: $itemFields.price)
                .font(.caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
            
            Text("Description")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            
            TextField("Description", text: $itemFields.description)
                .font(.caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    var imageSize = DaisyService.shared.mainWidth / 1.8
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(list.title)) {
                    VStack {
                        if itemFields.imageF != nil {
                            ItemImage(imageFile: itemFields.imageF, imageSize: ImageSize.itemEdit)
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        } else {
                            ItemImage(imageSize: ImageSize.itemEdit)
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        }
                        itemForm
                    }.listRowBackground(Color.dBackground)
                }
            } // Form
            .navigationBarTitle(Text("Add new Item"), displayMode: .inline)
            .navigationBarItems(leading: cancelButton,
                                trailing: doneButton
                                    .disabled(!itemFields.isValid)
            )
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .onAppear {
            if let itemToEdit = item {
                self.itemFields.title = itemToEdit.title
                self.itemFields.url = itemToEdit.url ?? "/"
                self.itemFields.price = String(format: "%.2f", itemToEdit.price ?? "0.00")
                self.itemFields.description = itemToEdit.description ?? ""
            }
        }
    }
    
    func doneAction() {
        if let imageForUpload = inputImage {
            self.imageViewModel.uploadImage(image: imageForUpload) { imageUploaded in
                if imageUploaded {
                    addItem(withImage: true)
                    self.showAddItem = false
                } else {
                    print("Sorry we cannot upload picture")
                }
            }
        } else {
            addItem(withImage: false)
            self.showAddItem = false
        }
        
    }
    
    func addItem(withImage: Bool) {
        self.itemViewModel.addItem(
            listID: self.list.id,
            title: self.itemFields.title,
            imageID: withImage ? self.imageID : nil,
            url: self.itemFields.url,
            price: Double(self.itemFields.price) ?? 0,
            description: self.itemFields.description)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.itemFields.imageF = Image(uiImage: inputImage)
    }
}

#if DEBUG
struct ItemEdit_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ItemEdit(
                itemViewModel: ItemsViewModel(list: staticList),
                showAddItem: .constant(false),
                list: staticList,
                item: nil)
            .environment(\.colorScheme, .light)
            
            ItemEdit(
                itemViewModel: ItemsViewModel(list: staticList),
                showAddItem: .constant(false),
                list: staticList,
                item: staticItem)
            .environment(\.colorScheme, .light)
        }
        
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
