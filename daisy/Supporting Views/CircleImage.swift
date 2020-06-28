//
//  CircleImage.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct CircleImage: View {
    let image: Image
    var body: some View {
            image
                .resizable()
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color("dDarkBlueColor"), lineWidth: 2))
                .shadow(radius: 10)
                .aspectRatio(contentMode: .fit)
    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage(image: Image("turtlerock"))
            .previewLayout(.sizeThatFits)
    }
}
