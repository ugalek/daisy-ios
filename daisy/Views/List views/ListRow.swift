//
//  ListRow.swift
//  daisy
//
//  Created by Galina on 22/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ListRow: View {
    var list: UserList
    
    var body: some View {
        HStack {
            ImageSquare(list: list, imageSize: ImageSize.itemRow)
            Text(list.title)
            Spacer()
            
            if list.surprise {
                Image(systemName: "sparkles")
                    .imageScale(.medium)
                    .foregroundColor(Color.dSurpriseColor)
            }
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListRow(list: staticList)
            ListRow(list: staticSurpriseList)
                .environment(\.colorScheme, .light)
            ListRow(list: staticSurpriseList)
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.fixed(width: 300, height: 140))
    }
}
