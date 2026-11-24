extension Poll {
    
    public struct OptionResult: Identifiable {
        public let option: Option
        public let voteShare: Double
        public let fractionOfLeadingVoteCount: Double
        public let isLeader: Bool

        public var id: Option.ID { option.id }

        init(
            option: Option,
            total: Int,
            maximum: Int
        ) {
            self.option = option
            voteShare = total > 0
                ? Double(option.voteCount) / Double(total)
                : 0
            fractionOfLeadingVoteCount = maximum > 0
                ? Double(option.voteCount) / Double(maximum)
                : 0
            isLeader = maximum > 0 && option.voteCount == maximum
        }
    }
    
}
