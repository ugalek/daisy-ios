//
//  TopGradient.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct TopGradient: View {
    var body: some View {
        LinearGradient(
        gradient: Gradient(colors: [Color("backgroundColor"), Color("lightBlueColor")]),
        startPoint: .bottom,
        endPoint: .top)
        .frame(height: 300)
        .edgesIgnoringSafeArea(.top)
    }
}

struct TopGradient_Previews: PreviewProvider {
    static var previews: some View {
        TopGradient()
            .previewLayout(.sizeThatFits)
    }
}
