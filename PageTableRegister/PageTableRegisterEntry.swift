//
//  PageTableRegisterEntry.swift
//  PageTableRegister
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

// struct to represent each page table entry
struct PageTableRegisterEntry {
    let pageNumber: Int
    var frameNumber: Int
    let sectorNumber: Int
    let validInvalid: Int
}
