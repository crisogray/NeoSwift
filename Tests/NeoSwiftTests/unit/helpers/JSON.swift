
import Foundation

public class JSON {
        
    public static func from(_ name: String) -> Data {
        let url = Bundle.module.url(forResource: name, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
}
