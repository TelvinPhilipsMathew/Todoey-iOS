//
//  Category.swift
//  Todoey
//
//  Created by Ancy Thomas on 1/22/18.
//  Copyright © 2018 ThinkPalm. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var title = ""
    @objc dynamic var color = ""
    let items = List<Item>()
}
