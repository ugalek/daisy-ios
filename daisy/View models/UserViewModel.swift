//
//  UserViewModel.swift
//  daisy
//
//  Created by Galina on 31/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var user = User()
    @Published var errorMessage = ""
    
    public init(userID: String) {
        fetchData(userID: userID)
    }
    
    private func fetchData(userID: String) {
        DaisyService.shared.searchUser(userID: userID) { response in
            if response.isSuccess {
                if let responseUser = response.model {
                    self.user = responseUser
                }
            }
        }
    }
    
    func editUser(oldUser: User, name: String, email: String, password: String, birthday: Date, imageID: String?, completion: @escaping(Bool) -> ()) {
        var body: [String: Any?] = [
            "name": name,
            "email": email,
            "password": nil,
            "birthday": birthday.toDateString(),
            "image_id": nil]
        
        if password != "" {
            body.updateValue(password, forKey: "password")
        }
        
        if let image = imageID {
            body.updateValue(image, forKey: "image_id")
        }
        
        DaisyService.shared.editUser(userID: oldUser.id, body: body) { response in
            if response.isSuccess {
                if let responseUser = response.model {
                    if let oldImageID = oldUser.imageID {
                        if oldImageID != imageID {
                            ImageViewModel().deleteImage(imageID: oldImageID)
                        }
                    }
                    self.user = responseUser
                    completion(false)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = response.errorMsg ?? "Something is wrong"
                    completion(true)
                }
            }
        }
    }
    
    func deleteUser(userID: String) {
        DaisyService.shared.deleteRequest(endpoint: .user(id: userID)) { _ in }
    }
}
