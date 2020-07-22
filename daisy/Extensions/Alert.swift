//
//  Alert.swift
//  daisy
//
//  Created by Galina on 22/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import SwiftUI

extension Alert {
    //  use like Alert(localizedError: itemViewModel.errorMessage!)
    init(localizedError: LocalizedError) {
        self = Alert(nsError: localizedError as NSError)
    }
    
    init(nsError: NSError) {
        let message: Text? = {
            let message = [nsError.localizedFailureReason,
                           nsError.localizedRecoverySuggestion].compactMap({ $0 }).joined(separator: "\n\n")
            return message.isEmpty ? nil : Text(message)
        }()
        self = Alert(title: Text(nsError.localizedDescription),
                     message: message,
                     dismissButton: .default(Text("OK")))
    }
}

public protocol Alerting {
    func errorAlert(message: String) -> Alert
}

extension Alerting {
    public func errorAlert(message: String) -> Alert {
        return Alert(title: Text("Error"), message: Text(message), dismissButton: .default(Text("OK")))
    }
}
