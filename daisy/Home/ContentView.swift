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
        VStack {
            if manager.authenticated {
                ListView(lists: [UserList]())
            } else {
                ConnectionView(manager: manager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




