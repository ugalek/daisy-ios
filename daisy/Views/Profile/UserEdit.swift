//
//  UserEdit.swift
//  daisy
//
//  Created by Galina on 02/08/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct UserEdit: View, Alerting {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var imageViewModel = ImageViewModel()
    @ObservedObject var userFields = UserFields()
    
    @Binding var showEditUser: Bool
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showAlert = false
    @State private var value: CGFloat = 0
    
    @State private var passwordNew: String = ""
    @State private var passwordConfirm: String = ""
    
    var user: User
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
            self.showEditUser = false
            self.presentationMode.wrappedValue.dismiss()
        })
        { Text("Cancel") }
    }
    
    @State private var birthdayD = Date()
    
    var body: some View {
        NavigationView {
            Form {
                VStack {
                    if userFields.image != nil {
                        ImageCircle(imageFile: userFields.image, imageSize: ImageSize.itemEdit)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        ImageCircle(user: user, imageSize: ImageSize.itemEdit)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }
                    VStack(alignment: .leading) {
                        Text("Name")
                            .font(.subheadline)
                            .foregroundColor(.dDarkBlueColor)
                        
                        FormatedTextField(
                            placeholder: "Name",
                            iconName: "person",
                            text: $userFields.name,
                            isValid: self.userFields.nameIsValid
                        )
                        if !self.userFields.nameIsValid {
                            Label("A maximum of 200 characters", systemImage: "exclamationmark.bubble")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        Text("Birthday")
                            .font(.subheadline)
                            .foregroundColor(.dDarkBlueColor)
                        
                        DatePicker("Birthday",
                                   selection: $userFields.birthdayDate, in: ...Date(),
                                   displayedComponents: .date)
                            .labelsHidden()
                            .colorMultiply(.dFontColor)
                            .overlay(
                                Image(systemName: "calendar")
                                    .padding(.horizontal)
                                    .foregroundColor(Color.gray),
                                alignment: .trailing)
                        
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.dDarkBlueColor)
                        
                        VStack(alignment: .leading) {
                            FormatedTextField(
                                placeholder: "example@email.com",
                                iconName: "envelope",
                                text: $userFields.email,
                                isValid: self.userFields.emailIsValid)
                            
                            if !self.userFields.emailIsValid {
                                Label("Email is not valid", systemImage: "exclamationmark.bubble")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Text("New password")
                                .font(.footnote)
                                .foregroundColor(.dDarkBlueColor)
                            FormatedTextField(
                                placeholder: "New password",
                                iconName: "lock.rectangle",
                                text: $passwordNew,
                                isSecured: true)
                            
                            Text("Confirm password")
                                .font(.footnote)
                                .foregroundColor(.dDarkBlueColor)
                            FormatedTextField(
                                placeholder: "Confirm password",
                                iconName: "lock.rectangle.on.rectangle",
                                text: $passwordConfirm,
                                isSecured: true)
                            
                            if passwordNew != passwordConfirm {
                                Label("The password confirmation does not match", systemImage: "exclamationmark.bubble")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                    }
                }.listRowBackground(Color.dBackground)
            } // Form
            .offset(y: -self.value)
            .animation(.spring())
            .navigationBarTitle(Text("Edit user"), displayMode: .inline)
            .navigationBarItems(leading: cancelButton,
                                trailing: doneButton
                                    .disabled(!userFields.isValid && (passwordNew == passwordConfirm))
            )
        }
        .modifier(DismissingKeyboardOnTapGesture())
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
        .onAppear {
            //Move view when keyboard is active
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                let height = value.height
                self.value = height
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                self.value = 0
            }
            
            self.userFields.name = user.name
            self.userFields.birthdayDate = user.birthdayDate
            self.userFields.email = user.email
        }
        .alert(isPresented: $showAlert, content: {
            errorAlert(message: userViewModel.errorMessage)
        })
    }
    
    func doneAction() {
        if let imageForUpload = inputImage {
            self.imageViewModel.uploadImage(image: imageForUpload) { imageUploaded in
                if imageUploaded {
                    editUser(withImage: true)
                    self.showEditUser = false
                } else {
                    print("Sorry we cannot upload picture")
                }
            }
        } else {
            editUser(withImage: false)
        }
    }
    
    func editUser(withImage: Bool) {
        self.userViewModel.editUser(
            oldUser: user,
            name: self.userFields.name,
            email: self.userFields.email,
            password: self.passwordNew,
            birthday: self.userFields.birthdayDate,
            imageID: withImage ? self.imageID : user.imageID)  { result in
            self.showAlert = result
            self.showEditUser = result
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        self.userFields.image = Image(uiImage: inputImage)
    }
}

struct UserEdit_Previews: PreviewProvider {
    static var previews: some View {
        UserEdit(userViewModel: UserViewModel(userID: ""),
                 showEditUser: .constant(true),
                 user: staticUser)
    }
}
