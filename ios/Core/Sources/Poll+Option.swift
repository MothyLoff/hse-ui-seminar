import Foundation
import Observation



extension Poll {
    
    @Observable
    public final class Option: Identifiable {
        public let id = UUID()
        
        public private(set) var title: String
        public private(set) var voteCount: Int
        
        weak var poll: Poll?
        
        init(
            poll: Poll,
            title: String,
            voteCount: Int = 0
        ) {
            self.poll = poll
            self.title = title
            self.voteCount = voteCount
        }
        
        public func remove() {
            poll?.options.removeAll(where: { $0.id == self.id })
            poll = nil
        }
        
        public func addVote() {
            self.voteCount += 1
            self.poll?.sortOptions()
        }
    }
    
}

extension Poll.Option {
    
    public var totalPollVoteCount: Int? {
        self.poll?.totalVoteCount
    }
    
    public var maxPollVoteCount: Int? {
        return switch self.poll?.maxVoteCount {
        case .noOptions, nil: nil
        case .value(let value): value
        }
    }
    
    public var majorityFraction: Double? {
        guard let poll else { return nil }
        switch poll.maxVoteCount {
        case .noOptions:
            return nil
        case .value(let count):
            guard count > 0 else { return 0 }
            return Double(voteCount) / Double(count)
        }
    }
    
    public var votePercentage: Int {
        guard
            let pollTotalVoteCount: Int = self.poll?.totalVoteCount,
            pollTotalVoteCount > 0
        else {
            return 0
        }
        let fraction = Double(self.voteCount) / Double(pollTotalVoteCount)
        return Int(fraction * 100)
    }
    
}


extension Poll.Option {
    
    public struct Maker {
        let title: String
        let voteCount: Int
        
        init(title: String, voteCount: Int) {
            self.title = title
            self.voteCount = voteCount
        }
        
        public static func option(_ title: String, voteCount: Int = 0) -> Self {
            return .init(title: title, voteCount: voteCount)
        }
        
        func add(to poll: Poll) -> Poll.Option {
            return .init(poll: poll, title: title, voteCount: voteCount)
        }
    }
    
}


public struct PollOption {
    let title: String
    let voteCount: Int
    
    public init(_ title: String, voteCount: Int = 0) {
        self.title = title
        self.voteCount = voteCount
    }
}


@resultBuilder
public enum PollOptionBuilder {
    
    public static func buildExpression(_ component: PollOption) -> [Poll.Option.Maker] {
        [Poll.Option.Maker(title: component.title, voteCount: component.voteCount)]
    }
    
    public static func buildBlock(_ components: [Poll.Option.Maker]...) -> [Poll.Option.Maker] {
        components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [[Poll.Option.Maker]]) -> [Poll.Option.Maker] {
        components.flatMap { $0 }
    }
    
}
