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
