//
//  FormatedTextField.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct FormatedTextField: View {
    let placeholder: String
    let iconName: String
    let text: Binding<String>
    let keyboardType: UIKeyboardType
    let isSecured: Bool
    let isValid: Bool
    
    init(placeholder: String,
         iconName: String,
         text: Binding<String>,
         keyboardType: UIKeyboardType = UIKeyboardType.default,
         isSecured: Bool = false,
         isValid: Bool = true) {
        
        self.placeholder = placeholder
        self.iconName = iconName
        self.text = text
        self.keyboardType = keyboardType
        self.isSecured = isSecured
        self.isValid = isValid
    }
    
    var body: some View {
        VStack {
            if isSecured {
                SecureField(placeholder, text: text)
                    .autocapitalization(.none)
                    .font(.footnote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        Image(systemName: iconName)
                            .padding(.horizontal)
                            .foregroundColor(!isValid ? .red : Color.dBorderColor),
                        alignment: .trailing)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .font(.footnote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(!isValid ? .red : .primary)
                    .overlay(
                        Image(systemName: iconName)
                            .padding(.horizontal)
                            .foregroundColor(!isValid ? .red : Color.dBorderColor),
                        alignment: .trailing)
            }
        }
    }
}

struct EmailTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FormatedTextField(
                placeholder: "email@example.com",
                iconName: "envelope",
                text: .constant("email@example.com"),
                isValid: false
            )
            
            FormatedTextField(
                placeholder: "password",
                iconName: "lock",
                text: .constant(""),
                isSecured: true
            )
        }
        .previewLayout(.sizeThatFits)
        
    }
}
