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
    let borderColor: UIColor
    
    init(placeholder: String,
         iconName: String,
         text: Binding<String>,
         keyboardType: UIKeyboardType = UIKeyboardType.default,
         isSecured: Bool = false,
         isValid: Bool = true,
         borderColor: UIColor = ColorPalette.gray3) {
        
        self.placeholder = placeholder
        self.iconName = iconName
        self.text = text
        self.keyboardType = keyboardType
        self.isSecured = isSecured
        self.isValid = isValid
        self.borderColor = borderColor
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                if isSecured {
                    SecureField(placeholder, text: text)
                        .autocapitalization(.none)
                        .font(.caption)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .font(.caption)
                }
                Image(systemName: iconName)
                    .foregroundColor(!isValid ? .red : Color(borderColor))
            }
            .padding(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(!isValid ? .red : Color(borderColor), lineWidth: 1))
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
