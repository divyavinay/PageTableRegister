//
//  Helper.swift
//  PageTableRegister
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation

class Helper {
    
    private var pageTable: PageTableRegister
    
    init(pageTableRegister: PageTableRegister) {
        self.pageTable = pageTableRegister
    }
    
    func getProgramInput() {
        var ans = ""
        pageTable.PTE = [PageTableRegisterEntry]()
        pageTable.PTEcache = [PageTableRegisterEntry]()
        pageTable.cache = [Int]()
        pageTable.sectorCache = [Int]()
        print("Enter number of pages in program")
        let numberOfPages = readLine()
        pageTable.numberOfPagesInProgram = Int(numberOfPages!)!
        print("Enter number of frames")
        let numberOfFrames = readLine()
        pageTable.createPTR(numberOfPagesInProgram: Int(numberOfFrames!)!)
        pageTable.printPTR()
        pageTable.getLogicalAddress(numberOfPages: pageTable.numberOfPagesInProgram)
        print("Enter Y to get next logical address for same program")
        ans = readLine()!
        while ans == "Y" {
            pageTable.getLogicalAddress(numberOfPages: pageTable.numberOfPagesInProgram)
            print("Enter Y to get next logical address for same program.")
            ans = readLine()!
        }
        
        var nextProgram = ""
        print("Enter Y for new program details")
        nextProgram = readLine()!
        while nextProgram == "Y" {
            getProgramInput()
            print("Enter Y for new program details")
            nextProgram = readLine()!
        }
    }
}
