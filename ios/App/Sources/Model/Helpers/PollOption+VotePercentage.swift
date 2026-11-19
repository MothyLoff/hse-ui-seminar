import PollarCore

extension Poll.Option {
    
    var isTopOption: Bool {
        return self.voteCount > 0
            && self.maxPollVoteCount == self.voteCount
    }
    
}
