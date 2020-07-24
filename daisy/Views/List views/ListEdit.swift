//
//  ListEdit.swift
//  daisy
//
//  Created by Galina on 24/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListEdit: View, Alerting {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var listViewModel: ListViewModel
    @ObservedObject var listFields = ListFields()
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showAlert = false
    @State private var title: String = ""
    
    @Binding var showAddList: Bool
    
    var list: UserList?
    var editMode: Bool = false
    
    private var doneButton: some View {
        Button(action: { self.doneAction() }) {
            Text("Done").bold()
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            self.showAddList = false
            self.presentationMode.wrappedValue.dismiss()
        })
        { Text("Cancel") }
    }
    
    private var viewTitle: String {
        get {
            if editMode {
                return "Edit list"
            } else {
                return "Add new list"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    if listFields.image != nil {
                        ItemImage(imageFile: listFields.image, imageSize: ImageSize.itemEdit)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        ItemImage(list: list, imageSize: ImageSize.itemEdit)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Title")
                                .font(.subheadline)
                                .foregroundColor(.dDarkBlueColor)
                            Spacer()
                            if !self.listFields.titleIsValid {
                                Text("A minimum of 3 characters")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        FormatedTextField(
                            placeholder: "Title",
                            iconName: "t.bubble",
                            text: $listFields.title,
                            isValid: self.listFields.titleIsValid
                        )
                        
                        Toggle(isOn: $listFields.surprise) { Text("Surprise") }
                            .font(.subheadline)
                            .foregroundColor(.dDarkBlueColor)
                    }
                }.listRowBackground(Color.dBackground)
            } // Form
            .navigationBarTitle(Text(viewTitle), displayMode: .inline)
            .navigationBarItems(leading: cancelButton,
                                trailing: doneButton
                                    .disabled(!listFields.isValid)
            )
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .onAppear {
            if let listToEdit = list {
                self.listFields.title = listToEdit.title
            }
        }
        .alert(isPresented: $showAlert, content: {
            errorAlert(message: listViewModel.errorMessage)
        })
    }
    
    func doneAction() {
        self.listViewModel.addList(
            title: self.title)
        self.showAddList = false
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.listFields.image = Image(uiImage: inputImage)
    }
}

struct ListEdit_Previews: PreviewProvider {
    static var previews: some View {
        ListEdit(
            listViewModel: ListViewModel(),
            showAddList: .constant(false))
    }
}
