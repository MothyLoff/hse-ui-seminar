extension Poll {
    
    public var results: Results? {
        guard status == .finished else {
            return nil
        }
        return Results(options: options)
    }

    public struct Results {
        public let totalVoteCount: Int
        public let options: [OptionResult]

        init(options: [Option]) {
            let total = options.reduce(0) { $0 + $1.voteCount }
            let maximum = options.lazy.map(\.voteCount).max() ?? 0

            self.totalVoteCount = total
            self.options = options.map {
                OptionResult(
                    option: $0,
                    total: total,
                    maximum: maximum
                )
            }
        }
    }
    
}
