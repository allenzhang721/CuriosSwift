//: Playground - noun: a place where people can play

import UIKit
import Mantle

var str = "Hello, playground"

class ClassA:  {
    
   var name = "Emiaostein"
}

let a = ClassA()

let b = ClassA()

let c: ClassA = b.copy() as! ClassA

let d = ClassA()

println(b.name)