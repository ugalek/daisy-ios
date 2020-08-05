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
    @EnvironmentObject var userViewModel: UserViewModel
    
//    var curentUser = staticUser
    var curentUser: User {
        get { return userViewModel.user }
    }
    
    @State var showEditUser = false
    private var editButton: some View {
        Button(action: { self.showEditUser = true }) {
            HStack{
                Image(systemName: "pencil")
                    .imageScale(.large)
                    .accessibility(label: Text("Edit user"))
            }
            .foregroundColor(.dDarkBlueColor)
        }
    }
    
    var body: some View {
        ZStack {
            Color.dBackground.edgesIgnoringSafeArea(.all)
            VStack {
                ImageCircle(user: curentUser, imageSize: ImageSize.itemDetail)
                    .padding(20)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(curentUser.name)
                            .font(.title)
                            .fontWeight(.thin)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        editButton
                    }
                    HStack(alignment: .top) {
                        Text(curentUser.email)
                            .font(.subheadline)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Text(curentUser.birthday)
                            .font(.subheadline)
                    }
                }
                .padding()
                .sheet(isPresented: $showEditUser) {
                    UserEdit(userViewModel: userViewModel, showEditUser: $showEditUser, user: curentUser)
                }
                
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
            UserView()
                .environment(\.colorScheme, .light)
        }
    }
}
