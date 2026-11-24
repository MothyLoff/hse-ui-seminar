import PollarCore


extension Poll.Option {

    enum TrailingContent {
        case none
        case voteCount(Int)
        case percentage(Double)

        var text: String? {
            switch self {
            case .none: nil
            case .voteCount(let count): String(count)
            case .percentage(let share): "\(Int(share * 100))%"
            }
        }

        var showsPersonIcon: Bool {
            if case .voteCount = self { return true }
            return false
        }
    }

}
