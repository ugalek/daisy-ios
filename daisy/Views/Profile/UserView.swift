//
//  UserView.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var authManager: HttpAuth
    
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            VStack {
                ZStack {
                    TopGradient()
                        .edgesIgnoringSafeArea(.top)
                    CircleImage(image: Image("turtlerock"))
                        .frame(width: 150, height: 150)
                        .padding(.bottom, 20)
                }
                UserInfo(userName: "Joe Doe", email: "joe@example.com", city: "California")
                Button(action: {
                    UserDefaults().removeObject(forKey: "token")
                    self.authManager.authenticated = false
                }
                ) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180, height: 40)
                        .background(Color.pink)
                        .cornerRadius(15.0)
                }
                Spacer()
            }
        }
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
