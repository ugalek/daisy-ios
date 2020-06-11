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
            list.imageStored
                .resizable()
                .frame(width: 50, height: 50)
            Text(list.title)
            Spacer()
            
            if list.surprise {
                Image(systemName: "sparkles")
                    .imageScale(.medium)
                    .foregroundColor(.purple)
            }
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ListRow(list: listData[0])
            ListRow(list: listData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
