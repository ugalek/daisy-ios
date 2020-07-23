//
//  ConnectionView.swift
//  daisy
//
//  Created by Galina on 20/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    @State private var apiLink: String = UserDefaults.standard.string(forKey: "apiLink") ?? ""
    
    private var ApiLinkText: some View {
        if apiLink != "/" {
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
                .foregroundColor(Color.gray)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    welcomeView()
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
                    settingsView(apiLink: self.$apiLink)
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

struct loginForm: View, Alerting {
    @EnvironmentObject var authManager: HttpAuth
    
    @State private var email: String = "admin@example.com"
    @State private var password: String = "admin"
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                FormatedTextField(
                    placeholder: "Email",
                    iconName: "envelope",
                    text: $email,
                    isValid: Validators.emailIsValid(email: email))
                
                if !Validators.emailIsValid(email: email) {
                    Label("Email is not valid", systemImage: "exclamationmark.bubble")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
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
                    .background(Color.dPrimaryButton)
                    .cornerRadius(15.0)
            }
        }
        .alert(isPresented: $authManager.showAlert, content: {
            errorAlert(message: authManager.errorMessage)
        })
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
                    .background(Color.dSecondaryButton)
                    .cornerRadius(15.0)
            }
        }
    }
}

struct settingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var apiLink: String
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("API address")
                    FormatedTextField(
                        placeholder: "http://website.com/api/v1",
                        iconName: "link.circle",
                        text: self.$apiLink)
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
                        .foregroundColor(Color.black)
                })
            }
        }
    }
}

struct ConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionView()
                .environment(\.colorScheme, .dark)
            ConnectionView()
                .environment(\.colorScheme, .light)
        }
    }
}
