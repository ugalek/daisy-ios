//
//  WishImage.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct WishImage: View {
    let image: Image
    var body: some View {
        image
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(
                RoundedRectangle(cornerRadius: 15).stroke(Color("darkBlueColor"), lineWidth: 2))
            .shadow(radius: 10)
            .aspectRatio(contentMode: .fit)
    }
}

struct WishImage_Previews: PreviewProvider {
    static var previews: some View {
        WishImage(image: Image("turtlerock"))
            .previewLayout(.sizeThatFits)
    }
}
