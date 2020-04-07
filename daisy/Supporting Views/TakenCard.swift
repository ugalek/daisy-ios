//
//  TakenCard.swift
//  daisy
//
//  Created by Galina on 06/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct TakenCard: View {
    var wish: Wish
    
    var body: some View {
        wish.takenImage?
            .resizable()
            .aspectRatio(3 / 2, contentMode: .fit)
            .overlay(TextOverlay(wish: wish))
    }
}

struct TextOverlay: View {
    var wish: Wish
    
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(
                colors: [Color.black.opacity(0.6), Color.black.opacity(0)]),
            startPoint: .bottom,
            endPoint: .center)
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().fill(gradient)
            VStack(alignment: .leading) {
                Text(wish.title)
                    .font(.title)
                    .bold()
                Text(wish.price)
            }
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct TakenCard_Previews: PreviewProvider {
    static var previews: some View {
        TakenCard(wish: taken[0])
    }
}
