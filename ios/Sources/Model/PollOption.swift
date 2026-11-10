//  Option.swift, created by Timowa on 10.11.2026

import Foundation
import Observation


@Observable
final class PollOption: Identifiable {
    
    weak var poll: Poll?

    var title: String
    var votes: Int
    
    init(poll: Poll? = nil, title: String, votes: Int) {
        self.poll = poll
        self.title = title
        self.votes = votes
    }
    
    var voteFraction: Double {
        guard let voteCount = poll?.voteCount, voteCount > 0 else { return 0 }
        return Double(votes) / Double(voteCount)
    }

    func fillPercent() -> Double? {
        guard let maxCount = self.poll?.maxVoteCount else { return nil }
        guard maxCount > 0 else { return 0 }
        return Double(votes) / Double(maxCount)
    }
    
}
