
import Foundation

extension Array {
    
    static func + (lhs: Array<Element>, rhs: Element) -> Array<Element> {
        return lhs + [rhs]
    }
    
    static func + (lhs: Element, rhs: Array<Element>) -> Array<Element> {
        return [lhs] + rhs
    }
    
}
