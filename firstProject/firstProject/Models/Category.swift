import Foundation
import SwiftData

@Model
final class Category {
    var name: String
    var retrospectives: [Retrospective] = []

    init(name: String) {
        self.name = name
    }
}
