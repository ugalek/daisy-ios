//
//  UserView.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct UserView: View {
    var body: some View {
        VStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("backgroundColor"), Color("lightBlueColor")]),
                startPoint: .bottom,
                endPoint: .top)
                .frame(height: 300)
                .edgesIgnoringSafeArea(.top)
            CircleImage()
                .offset(y: -130)
                .padding(.bottom, -130)

            VStack(alignment: .leading) {
                HStack {
                    Text("Joe Doe")
                        .font(.title)
                        .fontWeight(.thin)
                    Spacer()
                    Button(action: {
                        print("Edit tapped!")
                    }) {
                        Image(systemName: "pencil")
                            .font(.title)
                        .foregroundColor(Color("buttonColor"))
                    }
                }
                HStack(alignment: .top) {
                    Text("joe@example.com")
                        .font(.subheadline)
                    Spacer()
                    Text("California")
                        .font(.subheadline)
                }
            }
            .padding()
            Spacer()
        }
    .background(Color("backgroundColor"))
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
