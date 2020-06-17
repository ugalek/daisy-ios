//
//  ConnectionView.swift
//  daisy
//
//  Created by Galina on 20/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    @State private var apiLink = DaisyService.apiUrl.absoluteString
            
    private var ApiLinkText: some View {
        if apiLink != "" {
            return Text(apiLink)
                .font(.caption)
                .foregroundColor(.gray)
        } else {
            return Text("Please, setup the api link in the settings")
                .font(.caption)
                .foregroundColor(.red)
        }
    }
    
    @State var showingSettings = false
    var settingsButton: some View {
        Button(action: { self.showingSettings.toggle() }) {
            Image(systemName: "gear")
                .imageScale(.large)
                .accessibility(label: Text("App settings"))
                .foregroundColor(Color(ColorPalette.gray))
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                VStack {
                    ZStack {
                        TopGradient()
                            .edgesIgnoringSafeArea(.top)
                        welcomeView()
                    }
                    VStack(alignment: .center, spacing: 10) {
                        loginForm()
                        Divider()
                        Text("or use access to list of items")
                            .font(.caption)
                        magicAccess()
                        Spacer()
                        ApiLinkText
                    }
                    .padding(.horizontal)
                    .navigationBarItems(trailing: settingsButton)
                    .sheet(isPresented: $showingSettings) {
                        settingsView(apiLink: self.apiLink)
                    }
                }
            }
        }
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
    @EnvironmentObject var authManager: HttpAuth
    
    @State private var email: String = "admin@example.com"
    @State private var password: String = "admin"
    
    var body: some View {
        VStack {
            FormatedTextField(
                placeholder: "Email",
                iconName: "envelope",
                text: $email,
                isValid: Helpers().isValid(email: email))
            
            FormatedTextField(
                placeholder: "Password",
                iconName: "lock",
                text: $password,
                isSecured: true)
            
            Button(action: {
                print("\(self.email) and \(self.password)")
                self.authManager.login(email: self.email, password: self.password)
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
            FormatedTextField(
                placeholder: "Your access link",
                iconName: "wand.and.stars.inverse",
                text: $accessLink)
                      
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

struct settingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var apiLink: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColor").edgesIgnoringSafeArea(.all)
                VStack {
                    Text("API address")
                    FormatedTextField(
                        placeholder: "http://website.com/api/v1",
                        iconName: "link.circle",
                        text: self.$apiLink,
                        borderColor: ColorPalette.gray)
                    Spacer()
                }
                .padding()
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    if self.apiLink.last != "/" {
                        self.apiLink = self.apiLink + "/"
                    }
                    UserDefaults.standard.set(self.apiLink, forKey: "apiLink")
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done").bold()
                        .foregroundColor(Color(ColorPalette.black))
                })
                    //.navigationBarColor(UIColor(named: "lightBlueColor"))
            }
        }
    }
}
