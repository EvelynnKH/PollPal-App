//
//  Survey+Extention.swift
//  PollPal
//
//  Created by student on 08/12/25.
//

import Foundation


extension Survey {
    var categories: [Category] {
        (self.has_category?.allObjects as? [Category]) ?? []
    }
}
