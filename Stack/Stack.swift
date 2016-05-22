//
//  Stack.swift
//  Stack
//
//  Created by Roman Serga on 3/4/16.
//  Copyright © 2016 romikser. All rights reserved.
//

import Foundation

class Stack<ElementType> {
    
    var count : Int { get { return list.count } }
    var list = LinkedList<ElementType>()
    
    func push(element : ElementType) {
        list.append(element)
    }
    
    func pop() -> ElementType? {
        let lastIndex = count - 1
        
        guard let element = list.element(atIndex: lastIndex) else  {
            return nil
        }
        
        list.removeElement(atIndex: lastIndex)
        return element
    }
    
    func peek() -> ElementType? {
        return list.element(atIndex: 0)
    }
}

//MARK: Working With Files
extension Stack where ElementType : SimpleStringInitializable {
    convenience init(filePath : String) {
        self.init()
        self.list = LinkedList<ElementType>(filePath : filePath)
    }
}

extension Stack where ElementType : RadixStringInitializable {
    convenience init(filePath : String) {
        self.init()
        self.list = LinkedList<ElementType>(filePath : filePath)
    }
}

extension Stack where ElementType : CustomStringConvertible {
    func writeToFile(filePath : String, writeError : UnsafeMutablePointer<NSError>?) {
        list.writeToFile(filePath, writeError: writeError)
    }
}

//MARK: Conforming To SequenceType
extension Stack : SequenceType {
    func generate() -> AnyGenerator<ElementType> {
        return self.list.generate()
    }
}