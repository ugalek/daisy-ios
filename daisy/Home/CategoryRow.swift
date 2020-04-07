//
//  CategoryRow.swift
//  daisy
//
//  Created by Galina on 06/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct CategoryRow: View {
    var categoryName: String
    var items: [Wish]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(self.categoryName)
                .font(.headline)
                .padding(.leading, 15)
                .padding(.top, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(self.items) { wish in
                        NavigationLink(
                            destination: WishDetail(wish: wish)
                        ) {
                            CategoryItem(wish: wish)
                        }
                    }
                }
            }
        .frame(height: 185)
        }
    }
}

struct CategoryItem: View {
    var wish: Wish
    var body: some View {
        VStack(alignment: .leading) {
            wish.image
                .renderingMode(.original)
                .resizable()
                .frame(width: 155, height: 155)
                .cornerRadius(5)
            
            Text(wish.title)
                .foregroundColor(.primary)
                .font(.caption)
        }
        .padding(.leading, 15)
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(
            categoryName: wishData[0].category.rawValue,
            items: Array(wishData.prefix(3)))
            .previewLayout(.sizeThatFits)
    }
}
