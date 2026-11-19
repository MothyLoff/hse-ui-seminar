import Foundation
import Observation


@Observable
public final class Poll: Identifiable {
    
    public let id = UUID()
    
    public private(set) var title: String
    public private(set) var description: String?
    
    public internal(set) var options: [Option] = []
    
    public init(
        _ title: String,
        description: String? = nil,
        @PollOptionBuilder options makers: () -> [Poll.Option.Maker]
    ) {
        self.title = title
        self.description = description
        self.options = makers().map { $0.add(to: self) }
    }
    
    @discardableResult
    public func addOption(
        _ title: String,
        voteCount: Int = 0
    ) -> Option {
        let option = Option(
            poll: self,
            title: title,
            voteCount: voteCount
        )
        options.append(option)
        return option
    }
        
}


extension Poll {
    
    enum MaxVoteCount { case noOptions, value(Int) }
    
    var maxVoteCount: MaxVoteCount {
        guard let count = options.map(\.voteCount).max() else { return .noOptions }
        return .value(count)
    }
    
    
    public var totalVoteCount: Int { options.map(\.voteCount).reduce(0, +) }
    
}


extension Poll {
    
    func sortOptions() {
        options.sort { $0.voteCount > $1.voteCount }
    }
    
}
