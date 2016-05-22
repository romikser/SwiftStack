//
//  main.swift
//  Stack
//
//  Created by Roman Serga on 3/4/16.
//  Copyright © 2016 romikser. All rights reserved.
//

import Foundation

//Add here your file path to write and read from
let testFilePath : String = ""

func printSequence<T : SequenceType>(sequence : T) {
    for element in sequence { print(element) }
    print("\n")
}

extension Int : SimpleStringInitializable {
    init?(_ text: String) {
        self.init(text, radix: 10)
    }
}

func runListTests() {
    let list = LinkedList<Int>()
    
    for i in 0...9 { list.append(i) }
    
    printSequence(list)
    
    list.removeElement(atIndex: 0)
    list.removeElement(atIndex: list.count - 1)
    list.removeElement(atIndex: 2)
    
    printSequence(list)
    
    list.append(2)
    list.add(3, atIndex: 6)
    
    printSequence(list)
    
    list.add(3, atIndex: 16)
    list.removeElement(atIndex: 11)
    
    list.writeToFile(testFilePath, writeError: nil)
    
    let listFromFile : LinkedList<Int>
    listFromFile = LinkedList<Int>(filePath: testFilePath)
    
    printSequence(listFromFile)
}

func runStackTests() {
    let stack = Stack<Int>()
    
    for i in 0...10 { stack.push(i) }
    
    printSequence(stack)
    
    print(stack.pop())
    
    printSequence(stack)
    
    print(stack.peek())
    
    //Loading from file
    
    stack.writeToFile(testFilePath, writeError: nil)
    
    let listFromFile : LinkedList<Int>
    listFromFile = LinkedList<Int>(filePath: testFilePath)
    
    printSequence(listFromFile)
    
}

runStackTests()