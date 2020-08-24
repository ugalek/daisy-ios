//
//  ImageViewModel.swift
//  daisy
//
//  Created by Galina on 13/07/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import UIKit
import Combine

class ImageViewModel: ObservableObject {
    @Published var images: [ImageResponse] = []
    
    // used to store `AnyCancellable`, without keeping this reference alive, the network publisher will terminate immediately
    private var disposables = Set<AnyCancellable>()
    
    func uploadImage(image: UIImage?, completionHandler: @escaping (_ imageUploaded: Bool) -> Void) {
        if let image = image {
            DaisyService.shared.uploadImageRequest(endpoint: .images, image: image)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        completionHandler(true)
                    case .failure(_):
                        completionHandler(false)
                    }
                },
                receiveValue: {
                    self.images.append($0)
                })
                .store(in: &disposables)
        }
    }
    
    func deleteImage(imageID: String) {
        DaisyService.shared.deleteRequest(endpoint: .image(imageID: imageID)) { _,_  in }
    }
}
