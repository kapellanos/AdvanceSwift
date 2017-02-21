import Foundation

//: Playground - noun: a place where people can play

extension Sequence
{
     /// Returns the last element of the `Sequence` that conforms to `predicate`
     /// - parameter where: A closure that will be executed with all the elements of the `Sequence` to see if they match
     /// - Returns: The last element of the `Sequence` that match the predicate or nil if any element match the predicate
    /// <a name="anchor"></a>
    func last(where predicate: (Iterator.Element) -> Bool) -> Iterator.Element?
    {
        for element in reversed() where predicate(element) {
            return element
        }
        
        return nil
    }
}

//: Example <a href="#anchor">last</a>
let names = ["Paula", "Elena", "Zoe"]
let match = names.last { $0.hasSuffix("a") }
print(match!)

extension Array
{
    /// Returns the combination of each of the elements of the array applying `nextPartialResult`. See `reduce`
    /// - parameter initialResult: The initial result of the operations that will be combined
    /// - parameter nextPartialResult: The operation that will be executed in every element of the array to obtain a new result
    /// - Returns: An array with the combination of all the operations realized in all the elements
    func accumulate<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> [Result]
    {
        var running = initialResult
        
        return map { next in
            running = nextPartialResult(running, next)
            return running 
        }
    }
}

//: Example accumulate

let result = [1, 2, 3, 4].accumulate(0, +)
print(result)

extension Sequence
{
    /// Returns if all the elements of the `Sequence` match a predicate
    /// - parameter matching: The `predicate` that all the elements must match
    /// - Returns: `true` if all the elements match de predicate; `false` otherwise
    func all(matching predicate: (Iterator.Element) -> Bool) -> Bool
    {
        return !contains { !predicate($0) }
    }
}

//: Example all

let evenNumbers = [2, 4, 6, 8]

let allEven = evenNumbers.all(matching: { $0 % 2 == 0 })
print("\(allEven)")

let notAllEvenNumbers = [1, 2, 4, 6, 8]
let notAllEven = notAllEvenNumbers.all(matching: { $0 % 2 == 0 })
print("\(notAllEven)")

extension Dictionary
{
    /// Merge two `Sequence` of type (key, value) (dict or tuples) in self
    /// - parameter other: a `Sequence` to merge with self
    mutating func merge<S>(_ other: S) where S: Sequence, S.Iterator.Element == (key: Key, value: Value)
    {
        for (k, v) in other {
            self[k] = v
        }
    }
}


//: Example merge

enum Setting
{
    case text(String)
    case int(Int)
    case bool(Bool)
}

var defaultSettings: [String: Setting] = ["Airplane Mode": .bool(true), "Name": .text("My iPhone")]
let overriddenSettings: [String: Setting] = ["Name": .text("Jane's iPhone")]
defaultSettings.merge(overriddenSettings)
defaultSettings

extension Dictionary
{
    init<S: Sequence>(_ sequence: S) where S.Iterator.Element == (key: Key, value: Value)
    {
        self = [:]
        self.merge(sequence)
    }
}

//: Example init with sequence

let defaultAlarms = (1..<5).map {
    (key: "Alarm\($0)", value: false)
}
let alarmsDictionary = Dictionary(defaultAlarms)
alarmsDictionary

extension Dictionary
{
    /// Transform the values of a Dictionary maintaining the same keys
    /// - parameter transform: a function to be executed in each of the values of the dictionary
    /// - returns: a new `Dictionary` with the same keys as the original but the values transformed
    func mapValues<NewValue>(transform: (Value) -> NewValue) -> [Key: NewValue]
    {
        return Dictionary<Key, NewValue>(map {
            (key, value) in
            return (key, transform(value)) })
    }
}

//: Example mapValues

var defaultSettingsWithEnum: [String: Setting] = ["Airplane Mode": .bool(true), "Name": .text("My iPhone")]

let settingsAsStrings = defaultSettingsWithEnum.mapValues { setting -> String in
    switch setting {
    case .text(let text): return text
    case .int(let number): return String(number)
    case .bool(let value): return String(value)
    }
}

settingsAsStrings

/// Implementing hashable in custom types

extension Sequence where Iterator.Element: Hashable
{
    /// Returns an array, eliminating duplicates but maintaining the order
    /// - returns: a new `Sequence` without the duplicates
    func unique() -> [Iterator.Element]
    {
        var seen: Set<Iterator.Element> = []
        
        return filter {
            if seen.contains($0) {
                return false
            } else {
                seen.insert($0)
                return true
            }
        }
    }
}

//: Example unique

let uniqueArray = [1, 2, 3, 12, 1, 3, 4, 5, 6, 4, 6 ].unique()

print(uniqueArray)


// Using sequence we can iterate and generate elements of type UnfoldSequence
let randomNumbers = sequence(first: 100) {
    (previous: UInt32) in
    let newValue = arc4random_uniform(previous)
    guard newValue > 0 else {
        return nil
    }
    
    return newValue
}

print(Array(randomNumbers))

// With sequence with state, we can mantain the state between diferent iterations
let fibsSequence2 = sequence(state: (0, 1)) {
    (state: inout (Int, Int)) -> Int? in
    
    let upcomingNumber = state.0
    state = (state.1, state.0 + state.1)
    
    return upcomingNumber
}

print(Array(fibsSequence2.prefix(10)))

// Conforming to IteratorProtocol
struct PrefixIterator: IteratorProtocol
{
    let string: String
    var offset: String.Index
    
    init(string: String)
    {
        self.string = string
        offset = string.startIndex
    }
    
    // Returns a new slice of the String until the end of the String
    mutating func next() -> String?
    {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        
        return string[string.startIndex..<offset]
    }
}

// Conforming to Sequence
struct PrefixSequence: Sequence
{
    let string: String
    
    // Just return a new Prefix Iterator
    func makeIterator() -> PrefixIterator
    {
        return PrefixIterator(string: string)
    }
}

// Prints al the characters until the end of the String
for prefix in PrefixSequence(string: "Hello") {
    print(prefix)
}

// Now we can make any operation from 'Sequence'
print(PrefixSequence(string: "Hello").map({ $0.uppercased() }))

extension Sequence where Iterator.Element: Equatable, SubSequence: Sequence, SubSequence.Iterator.Element == Iterator.Element
{
    // Checks if the `head` of an Array is the same as the `tail`
    func headMirrorsTail(_ n: Int) -> Bool
    {
        let head = prefix(n)
        let tail = suffix(n).reversed()
        
        return head.elementsEqual(tail)
    }
}

// Example headMirrosTail
print([1, 2, 3, 4, 2, 1].headMirrorsTail(2))

// Making a protocol for Queues

/// A type that can `enqueue` and `dequeue` elements

protocol Queue
{
    /// The type of elements held in `self`
    associatedtype Element
    
    /// Enqueue `element` to `self`
    mutating func enqueue(_ newElement: Element)
    
    /// Dequeue an element from `self`
    mutating func dequeue() -> Element?
}

/// An efficient variable-size FIFO queue of elements of type `Element`

struct FIFOQueue<Element>: Queue
{
    fileprivate var left: [Element] = []
    fileprivate var right: [Element] = []
    
    /// Add an element to the back of the queue
    /// - Complexity: O(1)
    mutating func enqueue(_ newElement: Element)
    {
        right.append(newElement)
    }
    
    /// Rmoeves front of the queue
    /// Returns `nil` in case of an empty queue
    /// - Complexity: Amortized O(1)
    mutating func dequeue() -> Element?
    {
        if left.isEmpty {
            // Move the right elements reversed to the left array to make complexity O(1) instead of O(n)
            left = right.reversed()
            right.removeAll()
        }
        
        return left.popLast()
    }
}

// Making FIFOQueue conform to `Collection`

extension FIFOQueue: Collection
{
    var startIndex: Int { return 0 }
    var endIndex: Int { return left.count + right.count }
    
    func index(after i: Int) -> Int
    {
        precondition(i < endIndex)
        return i + 1
    }
    
    subscript(position: Int) -> Element {
        precondition((0..<endIndex).contains(position), "Index out of bounds")
        if position < left.endIndex {
            return left[left.count - position - 1] // left is reversed
        } else {
            return right[position - left.count]
        }        
    }
}