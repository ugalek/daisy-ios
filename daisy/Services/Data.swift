//
//  Data.swift
//  daisy
//
//  Created by Galina on 01/04/2020.
//  Copyright © 2020 Galina FABIO. All rights reserved.
//

import UIKit
import SwiftUI

let wishData: [Wish] = load("wishData.json")
let listData: [UserList] = load("listData.json")
let itemData: [Item] = load("itemData.json")

let taken = wishData.filter { $0.isTaken }
let surprise = listData.filter { $0.surprise }

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}


func getGridItemData(items: [Item]) -> [[Item]] {
    var item2D = [[Item]]()
    var counter = 0
    var tempItem = [Item]()
    
    for item in items {
        if counter < 2 {
            tempItem.append(item)
            counter += 1
        } else if counter == 2 {
            counter = 0
            item2D.append(tempItem)
            tempItem.removeAll()
            tempItem.append(item)
            counter += 1
        }
    }
    if counter != 0 {
        item2D.append(tempItem)
    }
    
    return item2D
}

func getGridItemDataByListID(listID: String) -> [[Item]] {
    var items = [Item]()
    var item2D = [[Item]]()
    var counter = 0
    var tempItem = [Item]()
    
    NetworkManager().genericFetch(urlString: "lists/\(listID)/items") { (i: ItemResults) in
        items = i.items
    }
    
    for item in items {
        if counter < 2 {
            tempItem.append(item)
            counter += 1
        } else if counter == 2 {
            item2D.append(tempItem)
        } else {
            tempItem.removeAll()
            counter = 0
        }
    }
    
    return item2D
}

