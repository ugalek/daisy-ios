//
//  EmailTextField.swift
//  daisy
//
//  Created by Galina on 17/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct FormatedTextField: View {
    let title: String
    let placeholder: String
    let iconName: String
    let text: Binding<String>
    let keyboardType: UIKeyboardType
    let isValid: (String) -> Bool
    
    init(title: String,
         placeholder: String,
         iconName: String,
         text: Binding<String>,
         keyboardType: UIKeyboardType = UIKeyboardType.default,
         isValid: @escaping (String)-> Bool = { _ in true}) {
        
        self.title = title
        self.placeholder = placeholder
        self.iconName = iconName
        self.text = text
        self.keyboardType = keyboardType
        self.isValid = isValid
    }
    
    var showsError: Bool {
        if text.wrappedValue.isEmpty {
            return false
        } else {
            return !isValid(text.wrappedValue)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(Color(.lightGray))
                .fontWeight(.bold)
            HStack {
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                Image(systemName: iconName)
                    .foregroundColor(.gray)
            }
            Rectangle()
                .frame(height: 2)
                .foregroundColor(showsError ? .red : Color(red: 189 / 255, green: 204 / 255, blue: 215 / 255))
        }
    }
}

struct EmailTextField_Previews: PreviewProvider {
    static var previews: some View {
        FormatedTextField(
            title: "Email",
            placeholder: "email@example.com",
            iconName: "envelope",
            text: .constant(""))
    }
}
