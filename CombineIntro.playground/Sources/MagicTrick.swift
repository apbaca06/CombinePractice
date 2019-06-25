import Foundation

public class MagicTrick: Decodable {
    public let name: String
    public static let placeholder = MagicTrick(name: "placeholder")
    
    init(name: String) {
        self.name = name
    }
}
