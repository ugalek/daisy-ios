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
    @ObservedObject var userViewModel: UserViewModel
    
    var curentUser: User {
        get { return userViewModel.user }
    }
    
    var body: some View {
        ZStack {
            Color.dBackground.edgesIgnoringSafeArea(.all)
            VStack {
                CircleImage(image: Image("turtlerock"))
                    .frame(width: 150, height: 150)
                    .padding(20)
                
                UserInfo(userName: curentUser.name, email: curentUser.email, birthday: curentUser.birthday)
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
                        .background(Color.dSecondaryButton)
                        .cornerRadius(15.0)
                }
                Spacer()
            }
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            UserView()
//                .environment(\.colorScheme, .dark)
            UserView(userViewModel: UserViewModel(userID: ""))
                .environment(\.colorScheme, .light)
        }
    }
}

struct UserInfo: View {
    let userName: String
    let email: String
    let birthday: String
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
                        .foregroundColor(Color.dPrimaryButton)
                }
            }
            HStack(alignment: .top) {
                Text(email)
                    .font(.subheadline)
                Spacer()
                Text(birthday)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}
