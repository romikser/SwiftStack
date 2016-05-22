//
//  LinkedList.swift
//  Stack
//
//  Created by Roman Serga on 3/4/16.
//  Copyright © 2016 romikser. All rights reserved.
//

import Foundation

protocol StorageType {
    associatedtype Element
    var count : UInt {get}
    func elementAt(index index : UInt) -> Element
    func setElement(element : Element, atIndex index : UInt)
    func removeAt(index index : UInt)
}

class Node<Type> {
    
    var content : Type

    private var previousNodePointer : UnsafeMutablePointer<Node<Type>>
    private var isPreviousNextNodeInitialized : Bool
    var previousNode : Node<Type>?
//        {
//        get {
//            return isNextNodeInitialized ? nextNodePointer.memory : nil
//        }
//        set {
//            if let newNextNode = newValue {
//                nextNodePointer.initialize(newNextNode)
//                isNextNodeInitialized = true
//            } else {
//                nextNodePointer.destroy()
//                isNextNodeInitialized = false
//            }
//        }
//    }
    
    private var nextNodePointer : UnsafeMutablePointer<Node<Type>>
    private var isNextNodeInitialized : Bool
    var nextNode : Node<Type>?
//        {
//        get {
//            return isNextNodeInitialized ? nextNodePointer.memory : nil
//        }
//        set {
//            if let newNextNode = newValue {
//                nextNodePointer.initialize(newNextNode)
//                isNextNodeInitialized = true
//            } else {
//                nextNodePointer.destroy()
//                isNextNodeInitialized = false
//            }
//        }
//    }
    
    init(content : Type, previousNode : Node<Type>? = nil, nextNode : Node<Type>? = nil) {
        self.content = content
        
        self.nextNodePointer = UnsafeMutablePointer<Node<Type>>.alloc(1)
        self.isNextNodeInitialized = false
        self.previousNodePointer = UnsafeMutablePointer<Node<Type>>.alloc(1)
        self.isPreviousNextNodeInitialized = false
        
        self.nextNode = nextNode
        self.previousNode = previousNode
    }
    
    deinit {
        nextNodePointer.destroy()
        nextNodePointer.dealloc(1)
        previousNodePointer.destroy()
        previousNodePointer.dealloc(1)
    }
}

class LinkedList<ElementType> {
    typealias ListNode = Node<ElementType>
    
    var head : ListNode? = nil
    var tail : ListNode? = nil
    var count = 0
    
    //MARK: Public Methods : Working With Elements

    func append(element : ElementType) {
        let newNode = Node(content: element)
        append(newNode)
    }
    
    func add(element: ElementType, atIndex index : Int) {
        let newNode = Node(content: element)
        add(newNode, atIndex: index)
    }
    
    func element(atIndex index : Int) -> ElementType? {
        let node = self.node(atIndex: index)
        return node?.content
    }
    
    func removeElement(atIndex index : Int) {
        if let node = node(atIndex: index) {
            self.remove(node)
        }
    }
    
    //MARK: Private Methods : Working With Nodes
    
    private func node(atIndex index : Int) -> ListNode? {
        guard index < count else {
            print("The index " + String(index) + " is out of bounds")
            return nil
        }
        
        var currentNode = head
        
        if index == count - 1 {
            currentNode = tail
        } else {
            for i in 0..<count {
                if i == index { break }
                currentNode = currentNode?.nextNode
            }
        }
        
        return currentNode
    }
    
    private func add(node: ListNode, atIndex index : Int) {
        guard index <= count else {
            print("The index " + String(index) + " is out of bounds")
            return
        }
        
        if let nextNode = self.node(atIndex: index) {
            if let previousNode = nextNode.previousNode {
                previousNode.nextNode = node
                node.previousNode = previousNode
            }
            nextNode.previousNode = node
            node.nextNode = nextNode
        } else {
            append(node)
        }
    }
    
    private func append(node : ListNode) {
        guard head != nil else {
            head = node
            tail = head
            return
        }
        
        if let lastNode = tail {
            lastNode.nextNode = node
            node.previousNode = lastNode
            tail = lastNode.nextNode!
        }
        
        count += 1
    }
    
    private func remove(node : ListNode) {
        guard let firstNode = head, let lastNode = tail else {
            print("The list is empty")
            return
        }
        
        if node === firstNode {
            if let secondNode = firstNode.nextNode {
                head = secondNode
                secondNode.previousNode = nil
            }
        } else if node === lastNode {
            if let penultNode = lastNode.previousNode {
                tail = penultNode
                penultNode.nextNode = nil
            }
        } else {
            if let previousNode = node.previousNode, let nextNode = node.nextNode {
                previousNode.nextNode = nextNode
                nextNode.previousNode = previousNode
            }
        }
    }
}

protocol SimpleStringInitializable {
    init?(_ text: String)
}

protocol RadixStringInitializable {
    init?(_ text: String, radix: Int)
}

//MARK: Working With Files
extension LinkedList where ElementType : SimpleStringInitializable {
    convenience init(filePath : String) {
        self.init()
        if let fileContent = try? String(contentsOfFile: filePath) {
            for line in fileContent.componentsSeparatedByString("\n") {
                if let elementFromString = ElementType(line) {
                    append(elementFromString)
                }
            }
        }
    }
}

extension LinkedList where ElementType : RadixStringInitializable {
    convenience init(filePath : String) {
        self.init()
        if let fileContent = try? String(contentsOfFile: filePath) {
            for line in fileContent.componentsSeparatedByString("\n") {
                if let elementFromString = ElementType(line, radix: 10) {
                    append(elementFromString)
                }
            }
        }
    }
}

extension LinkedList where ElementType : CustomStringConvertible {
    func writeToFile(filePath : String, writeError : UnsafeMutablePointer<NSError>?) {
        
        let fileManager = NSFileManager.defaultManager()
        let fileDirectory = (filePath as NSString).stringByDeletingLastPathComponent
        
        do {
            if !fileManager.fileExistsAtPath(filePath) {
                try fileManager.createDirectoryAtPath(fileDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let elementsConverted = self.map(){$0.description}
            try elementsConverted.joinWithSeparator("\n").writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
        }
        catch {
            writeError?.memory = NSError(domain: "Can't write to file" + filePath, code: 666, userInfo:nil)
        }
    }
}

//MARK: Conforming To SequenceType
extension LinkedList : SequenceType {
    
    func generate() -> AnyGenerator<ElementType> {
        
        var lastNode : ListNode?
        
        return AnyGenerator(body: { () -> ElementType? in
            if lastNode == nil {
                lastNode = self.head
            } else {
                lastNode = lastNode?.nextNode
            }
            return lastNode?.content
        })
    }
    
}
