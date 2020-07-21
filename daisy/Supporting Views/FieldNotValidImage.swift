//
//  FieldNotValidImage.swift
//  daisy
//
//  Created by Galina on 20/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct FieldNotValidImage: View {
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
