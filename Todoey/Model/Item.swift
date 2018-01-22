//
//  Item.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/22/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var createdDate = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
