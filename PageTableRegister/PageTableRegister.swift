//
//  PageTableRegister.swift
//  PageTableRegister
//
//  Created by Divya Basappa on 1/11/18.
//  Copyright © 2018 Divya Basappa. All rights reserved.
//

import Foundation


class PageTableRegister {
    
    let pageSize = 16
    let offsetBits = 4
    let virtualAddrBits = 14    // number of bits in Logical address
    let physicalAddrBits = 10   // number of bits in physical address
    var numberOfPagesInProgram = 0
    var numberOfFrames = 0
    var PTE = [PageTableRegisterEntry]()    // array of page table entries
    var PTEcache = [PageTableRegisterEntry]()
    var offset = ""
    let numberOfSectors = 100
    
    var cache = [Int]()
    var sectorCache = [Int]()
    
    func generateRandomNumber() -> Int {
        let random = arc4random_uniform(UInt32(numberOfPagesInProgram))
        if cache.contains(Int(random)) {
            return generateRandomNumber()
        }
        cache.append(Int(random))
        return Int(random)
    }
    
    // generateSectorNumber: function generates a random number between 0 to 100 which is number of sectors
    func generateSectorNumber() -> Int {
        let random = arc4random_uniform(UInt32(numberOfSectors))
        if sectorCache.contains(Int(random)) {
            return generateSectorNumber()
        }
        // adds the generated number to cache to ensure that same number is not generated again.
        sectorCache.append(Int(random))
        return Int(random)
    }
    
    // printPTR: function prints the page table register
    func printPTR() {
        print("============= Page Table Register ==============")
        for i in 0..<PTE.count {
            let entry = PTE[i]
            print("Page Number: \(entry.pageNumber)")
            print("Frame Number: \(entry.frameNumber)")
            print("Sector Number: \(entry.sectorNumber)")
            print("Valid/Invalid: \(entry.validInvalid)")
            print ("---------------------------------------")
        }
    }
    
    // createPTR: function creates the initial page table register
    func createPTR(numberOfPagesInProgram: Int) {
        var count = 0
        while count < numberOfPagesInProgram {
            let frameNumber = generateRandomNumber()
            let sectorNumber = generateSectorNumber()
            let PTRentry = PageTableRegisterEntry(pageNumber: count, frameNumber: frameNumber, sectorNumber: sectorNumber, validInvalid: 1)
            PTE.append(PTRentry)
            count = count + 1
        }
    }
    
    // binaryToInt: Helper function to convert binary to int.
    func binaryToInt(binaryString: String) -> Int {
        return Int(strtoul(binaryString, nil, 2))
    }
    
    // splitString: Function splits the logical address into page number and offset bits
    func splitString(str: String, pageNumberBits: Int) -> (String, String) {
        var count = 0
        var allowedString = ""
        var excessString = ""
        if str.count < pageNumberBits {
            allowedString = str
        }
        else {
            for c in str {
                if count < pageNumberBits {
                    count+=1
                    allowedString.append(c)
                } else {
                    excessString.append(c)
                }
            }
        }
        return (allowedString, excessString)
    }
    
    // getPageNumberFromLogicalAddress: function gets the page number of logical address
    func getPageNumberFromLogicalAddress(logicalAddress: UInt32) {
        let logicalAddBin = getBinaryRep(address: logicalAddress, toSize: 14)
        let str = splitString(str: logicalAddBin, pageNumberBits: virtualAddrBits - offsetBits)
        let pageNumberBits = str.0
        print("Page Number Bits: \( pageNumberBits)")
        print("Page Number: \(binaryToInt(binaryString: pageNumberBits))")
        print("Offset Bits: \(str.1)")
        print("Offset: \(binaryToInt(binaryString: str.1))")
        offset = str.1
        getPhysicalAddress(pageNumber: binaryToInt(binaryString: pageNumberBits))
    }
    
    // getBinaryRep: Helper function to get binary representation of Int value
    func getBinaryRep(address: UInt32, toSize: Int) -> String {
        let str = String(address, radix: 2)
        
        var binaryRep = str
        for _ in 0..<(toSize - str.characters.count) {
            binaryRep = "0" + binaryRep
        }
        print("Binary representation:\(binaryRep)")
        return binaryRep
    }
    
    // getLogicalAddress: Function generates a logical address between 0 and numberOfPages * pageSize
    func getLogicalAddress(numberOfPages: Int) {
        print("================ Logical Address Details ==================")
        let logicalAddress = arc4random_uniform(UInt32(numberOfPages * pageSize))
        print("The logical address is: \(logicalAddress)")
        getPageNumberFromLogicalAddress(logicalAddress: logicalAddress)
    }
    
    // getPhysicalAddress: function calculates and prints physical address for the Logical address
    func getPhysicalAddress(pageNumber: Int) {
        print("============== Physical Address ===============")
        for i in 0..<PTE.count {
            // checks if the current page is in PTR
            if PTE[i].pageNumber == pageNumber {
                print("Frame Number: \(PTE[i].frameNumber)")
                print("Sector Number: \(PTE[i].sectorNumber)")
                print("Offset bits: \(offset)")
                print("Offset: \(binaryToInt(binaryString: offset))")
                let frameBits = String(PTE[i].frameNumber, radix: 2)
                let str =  frameBits + offset
                if str.count < physicalAddrBits - offsetBits
                {
                    let physicalAddr = addPadding(address: str, toSize: physicalAddrBits)
                    print("Physical Address: \(binaryToInt(binaryString: physicalAddr))")
                }
                else {
                    print("Physical Address: \(binaryToInt(binaryString: str))")
                }
                return
            }
        }
        // if page is not in PTR it checks cache to see if page has been swapped
        for i in 0..<PTEcache.count {
            if PTEcache[i].pageNumber == pageNumber {
                print("Page fault")
                getPageFromCache(pageNumber: pageNumber, index: i)
            }
        }
        //print("Page fault")
        getReplacementPage(pageNumber: pageNumber)
    }
    
    // getPageFromCache: function returns page table entry from cache
    func getPageFromCache(pageNumber: Int, index: Int) {
        let victimIndex = arc4random_uniform(UInt32(PTE.count))
        let victimPage = PTE.remove(at: Int(victimIndex))
        var PTRentry = getPageFromCache(pageNumber: pageNumber)
        
        PTRentry?.frameNumber = victimPage.frameNumber
        PTE.insert(PTRentry!, at: Int(victimIndex))
        PTEcache.insert(victimPage, at: index)
        printPTR()
        getPhysicalAddress(pageNumber: pageNumber)
    }
    
    func addPadding(address: String, toSize: Int) -> String {
        var binaryRep = address
        for _ in 0..<(toSize - address.characters.count) {
            binaryRep = "0" + binaryRep
        }
        return binaryRep
    }
    
    // getReplacementPage: function gets replacement page. Uses random replacement strategy
    func getReplacementPage(pageNumber: Int) {
        let victimIndex = arc4random_uniform(UInt32(PTE.count))
        let victimPage = PTE.remove(at: Int(victimIndex))
        PTEcache.append(victimPage)
        //let frameNumber = generateRandomNumber()
        let sectorNumber = generateSectorNumber()
        let PTRentry = PageTableRegisterEntry(pageNumber: pageNumber, frameNumber: victimPage.frameNumber, sectorNumber: sectorNumber, validInvalid: 1)
        PTE.insert(PTRentry, at: Int(victimIndex))
        printPTR()
        getPhysicalAddress(pageNumber: pageNumber)
    }
    
    
    func getPageFromCache(pageNumber: Int) -> PageTableRegisterEntry? {
        for i in 0..<PTEcache.count {
            if PTEcache[i].pageNumber == pageNumber {
                return PTEcache[i]
            }
        }
        return nil
    }    
}
