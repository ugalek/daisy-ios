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
            TopGradient()
            CircleImage(image: Image("turtlerock"))
                .offset(y: -230)
                .padding(.bottom, -230)
            UserInfo(userName: "Joe Doe", email: "joe@example.com", city: "California")
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

struct UserInfo: View {
    let userName: String
    let email: String
    let city: String
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(userName)
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
                Text(email)
                    .font(.subheadline)
                Spacer()
                Text(city)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}
