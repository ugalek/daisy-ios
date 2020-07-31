//
//  ItemEdit.swift
//  daisy
//
//  Created by Galina on 27/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Combine
import SwiftUI

struct ItemEdit: View, Alerting {
    
    @ObservedObject var itemViewModel: ItemsViewModel
    @ObservedObject var imageViewModel = ImageViewModel()
    @ObservedObject var itemFields = ItemFields()

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showAlert = false
    
    @Binding var showAddItem: Bool
        
    let list: UserList
    var item: Item?
    var editMode: Bool = false
    
    var imageID: String? {
        get {
            if imageViewModel.images.count == 0 {
                return nil
            } else {
                return imageViewModel.images[imageViewModel.images.count-1].id
            }
        }
    }
    
    private var viewTitle: String {
        get {
            if editMode {
                return "Edit item"
            } else {
                return "Add new item"
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
            
            FormatedTextField(
                placeholder: "Title",
                iconName: "t.bubble",
                text: $itemFields.title,
                isValid: self.itemFields.titleIsValid
            )
 
            Text("URL")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            
            FormatedTextField(
                placeholder: "URL (http://example.com)",
                iconName: "network",
                text: $itemFields.url
            )
            
            Text("Price")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            
            FormatedTextField(
                placeholder: "Price",
                iconName: "dollarsign.circle",
                text: $itemFields.price,
                keyboardType: .decimalPad
            )
            
            Text("Description")
                .font(.subheadline)
                .foregroundColor(.dDarkBlueColor)
            Section {
                TextEditor(text: $itemFields.description)
                    .font(.footnote)
                    .lineSpacing(5)
            }
            .frame(height: 150)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(list.title)) {
                    VStack {
                        if itemFields.image != nil {
                            ItemImage(imageFile: itemFields.image, imageSize: ImageSize.itemEdit)
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        } else {
                            ItemImage(item: item, imageSize: ImageSize.itemEdit)
                                .onTapGesture {
                                    showingImagePicker = true
                                }
                        }
                        itemForm
                    }.listRowBackground(Color.dBackground)
                }
            } // Form
            .navigationBarTitle(Text(viewTitle), displayMode: .inline)
            .navigationBarItems(leading: cancelButton,
                                trailing: doneButton
                                    .disabled(!itemFields.isValid)
            )
        }
        .modifier(DismissingKeyboardOnTapGesture())
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
        .alert(isPresented: $showAlert, content: {
            errorAlert(message: itemViewModel.errorMessage)
        })
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
        }
        
    }
    
    func addItem(withImage: Bool) {
        if editMode {
            self.itemViewModel.editItem(
                oldItem: item!,
                listID: self.list.id,
                title: self.itemFields.title,
                imageID: withImage ? self.imageID : item?.imageID,
                url: self.itemFields.url,
                price: Double(self.itemFields.price) ?? 0,
                description: self.itemFields.description) { result in
                self.showAlert = result
                self.showAddItem = result
            }
        } else {
            self.itemViewModel.addItem(
                listID: self.list.id,
                title: self.itemFields.title,
                imageID: withImage ? self.imageID : nil,
                url: self.itemFields.url,
                price: Double(self.itemFields.price) ?? 0,
                description: self.itemFields.description)
            self.showAddItem = false
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.itemFields.image = Image(uiImage: inputImage)
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
                item: nil,
                editMode: false)
            .environment(\.colorScheme, .light)
            
//            ItemEdit(
//                itemViewModel: ItemsViewModel(list: staticList),
//                showAddItem: .constant(false),
//                list: staticList,
//                item: staticItem,
//                editMode: false)
//            .environment(\.colorScheme, .light)
        }
        
    }
}
#endif
