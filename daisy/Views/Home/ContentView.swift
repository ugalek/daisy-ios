//
//  ContentView.swift
//  daisy
//
//  Created by Galina on 31/03/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: HttpAuth
    
    var body: some View {
        VStack {
            if auth.authenticated {
                AnyView(ListView(lists: [UserList]()))
            } else {
                AnyView(ConnectionView())
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




