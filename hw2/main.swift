import Foundation

print("Task 1")

class Apartment {
    let number: Int
    weak var tenant: Person? // use weak here to break the retain cycle (first part of the task1)
    // unowned var tenant: Person?
    
    init(number: Int) {
        self.number = number
    }
    
    func getInfo() {
        print("Apartment \(number) hosting \(tenant?.name.description ?? "empty")")
    }
    
    deinit {
        print("Apartment deinitialized")
    }
}

class Person {
    let name: String
    var apartment: Apartment?
    // weak var apartment: Apartment?
    // unowned var apartment: Apartment?
    
    init(name: String) {
        self.name = name
    }
    
    func setupApartment(_ apartment: Apartment) {
        self.apartment = apartment
    }
    
    func getInfo() {
        print("Person \(name) is in Apartment \(apartment?.number.description ?? "empty")")
    }
    
    deinit {
        print("Person deinitialized")
    }
}

var person: Person? = Person(name: "Yaroslava")

person?.setupApartment(Apartment(number: 42))

person?.apartment?.tenant = person
person?.getInfo()
person?.apartment?.getInfo()

person = nil

// - If we set weak or unowned only for Person in Apartment, the code works correctly. The Apartment may or may not have a Person, and both objects can be deallocated when no longer in use.
// - If we set weak for Apartment in Person, only the Person is deinitialized when we set person = nil, but the Apartment remains in memory, as there's no strong reference for it.
// - But if we set unowned for Apartment in Person we have Fatal error: Attempted to read an unowned reference but object 0x600000200be0 was already deallocated. This happens because unowned doesn't allow nil, and if Apartment deallocates first, Person crashes when accessing it.
// - We can make both Person in Apartment and Apartmnet in Person weak - but then only Person will be deinitialized when person = nil. It happens since weak references allowing Person to be deallocated while Apartment remains in memory without being explicitly deallocated.
// - When we set for `Person` and `Apartment` objects unowned - we have error Fatal error: Attempted to read an unowned reference but object 0x6000002012e0 was already deallocated.
// This happens since both objects assume the other will never be deallocated first, which causes a crash when either one deallocates early.

print("Task 2")

class NeighborNode<Value: Equatable> {
    weak var node: Node<Value>?
    
    init(_ node: Node<Value>) {
        self.node = node
    }
}

class Node<Value: Equatable> {
    var value: Value
    var children: [Node]
    var neighbors: [NeighborNode<Value>]
    
    init(_ value: Value) {
        self.value = value
        children = []
        neighbors = []
    }
    
    func add(_ child: Node) {
        children.append(child)
    }
    
    func addNeighbor(_ node: Node) {
        neighbors.append(NeighborNode(node))
    }
    
    func displayNeighbors() {
        let neighborValues = neighbors.compactMap { $0.node?.value }
        if neighborValues.isEmpty {
            print("Node \(value) has no neighbors.")
        } else {
            print("Node \(value) has neighbors: \(neighborValues)")
        }
    }
}

class Tree<Value: Equatable> {
    let root: Node<Value>

    init(root: Node<Value>) {
        self.root = root
    }
    
    func computeDepth(of node: Node<Value>? = nil) -> Int {
        let currentNode = node ?? root
        if currentNode.children.isEmpty {
            return 1
        }
     
        return 1 + currentNode.children.map { computeDepth(of: $0) }.max()!
    }

    func searchValueDFS(_ value: Value, from node: Node<Value>? = nil) -> Node<Value>? {
        let currentNode = node ?? root
        
        guard currentNode.value != value else {
            return currentNode
        }
  
        for child in currentNode.children {
            if let nextChild = searchValueDFS(value, from: child) {
                return nextChild
            }
        }

        return nil
    }
}

var rootNode = Node("Root")

var child1 = Node("Child 1")
var child2 = Node("Child 2")
var child3 = Node("Child 3")
var child4 = Node("Child 4")
var child5 = Node("Child 5")
var child6 = Node("Child 6")

child1.addNeighbor(child2)
child2.addNeighbor(child1)
child3.addNeighbor(child6)
child6.addNeighbor(child3)
child4.addNeighbor(child5)
child5.addNeighbor(child4)

child1.displayNeighbors()
child2.displayNeighbors()
child3.displayNeighbors()
child4.displayNeighbors()
child5.displayNeighbors()
child6.displayNeighbors()

// part from the previous hw:

child1.add(child6)
child2.add(child3)
child3.add(child4)
child3.add(child5)

rootNode.add(child1)
rootNode.add(child2)

let tree = Tree(root: rootNode)

let depth = tree.computeDepth()
print("Tree Depth: \(depth)")

if let foundNodeByValue = tree.searchValueDFS("Child 5") {
    print("Node found with value: \(foundNodeByValue.value)")
} else {
    print("Value not found in the tree.")
}

print("Task 3")

class ArrayWrapper {
    var array: [Int]
    
    init(_ array: [Int]) {
        self.array = array
    }
    
    func append(_ newElement: Int) {
        self.array.append(newElement)
    }
}

struct MyData {
    var myArray: ArrayWrapper
    
    init(_ array: [Int]) {
        myArray = ArrayWrapper(array)
    }
    
    mutating func append(_ newElement: Int) {
        if !isKnownUniquelyReferenced(&myArray) {
            myArray = ArrayWrapper(myArray.array)
        }
        myArray.array.append(newElement)
    }
    
    func printData() {
        print(myArray.array)
    }
}

var array = [1, 2, 3, 4]
var data = MyData(array)
var data2 = data

data2.append(1)

data.printData()
data2.printData()
