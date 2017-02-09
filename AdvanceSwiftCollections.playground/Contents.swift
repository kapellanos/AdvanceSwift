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
