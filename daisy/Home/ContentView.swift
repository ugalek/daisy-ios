//
//  ContentView.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var manager = HttpAuth()
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            welcomeView()
            if manager.authenticated {
                Text("You are authenticated")
            } else {
                Text("You are not authenticated")
            }
            loginForm(manager: manager)
            Divider()
            Text("or use access to list of items")
                .font(.caption)
            magicAccess()
            Spacer()
            Text("http://localhost:3000/api/v1")
                .font(.caption)
                .foregroundColor(.gray)
        }
    .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct welcomeView: View {
    var body: some View {
        VStack {
            Text("Welcome!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.bottom, 20)
            CircleImage(image: Image("turtlerock"))
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)
        }
    }
}

struct loginForm: View {
    
    @State private var email: String = "admin@example.com"
    @State private var password: String = "admin"
    
    @ObservedObject var manager: HttpAuth
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person")
                    .foregroundColor(.gray)
                
                TextField("Email", text: $email)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            HStack {
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                SecureField("Password", text: $password)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Button(action: {
                print("\(self.email) and \(self.password)")
                self.manager.checkDetails(email: self.email, password: self.password)
            }
            ) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 180, height: 40)
                    .background(Color.pink)
                    .cornerRadius(15.0)
            }
        }
    }
}

struct magicAccess: View {
    
    @State private var accessLink: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "wand.and.stars.inverse")
                    .foregroundColor(.gray)
                TextField("Your access link", text: $accessLink)
                    .font(.caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Button(action: {
                print("magic link")
            }
            ) {
                Text("Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 180, height: 40)
                    .background(Color.orange)
                    .cornerRadius(15.0)
            }
        }
    }
}
