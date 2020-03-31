//
//  CircleImage.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
            Image("pic")
                .resizable()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color("darkBlueColor"), lineWidth: 2))
                .shadow(radius: 10)
                .scaledToFit()

    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
