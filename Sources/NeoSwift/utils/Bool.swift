
import Foundation

extension Bool {
    
    func assert(_ message: String) throws {
        if !self { throw message }
    }
    
}
