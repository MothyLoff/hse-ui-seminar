import PollarCore
import Testing

@Suite("Poll")
struct PollTests {
    @Test func createsActivePollInInputOrder() throws {
        let poll = try Poll(
            title: " Куда? ",
            description: " \n ",
            optionTitles: [" А ", "Б"]
        )

        #expect(poll.title == "Куда?")
        #expect(poll.description == nil)
        #expect(poll.status == .active)
        #expect(!poll.isArchived)
        #expect(poll.options.map(\.title) == ["А", "Б"])
        #expect(poll.options.map(\.voteCount) == [0, 0])
        #expect(poll.results == nil)
    }

    @Test func rejectsInvalidInput() {
        #expect(throws: Poll.CreationError.emptyTitle) {
            try Poll(
                title: " \n ",
                optionTitles: ["А", "Б"]
            )
        }
        #expect(throws: Poll.CreationError.tooFewOptions) {
            try Poll(
                title: "Куда?",
                optionTitles: ["А"]
            )
        }
        #expect(throws: Poll.CreationError.emptyOptionTitle) {
            try Poll(
                title: "Куда?",
                optionTitles: ["А", "Б", "  "]
            )
        }
    }

    @Test func votesPreserveIDsAndOrder() throws {
        let poll = try Poll(
            title: "Куда?",
            optionTitles: ["А", "Б", "В"]
        )
        let ids = poll.options.map(\.id)
        try poll.vote(for: ids[2])
        try poll.vote(for: ids[2])

        #expect(poll.options.map(\.id) == ids)
        #expect(poll.options.map(\.voteCount) == [0, 0, 2])
        #expect(poll.results == nil)
    }

    @Test func rejectsOptionFromAnotherPoll() throws {
        let poll = try Poll(
            title: "Куда?",
            optionTitles: ["А", "Б"]
        )
        let other = try Poll(
            title: "Когда?",
            optionTitles: ["А", "Б"]
        )
        #expect(throws: Poll.VotingError.unknownOption) {
            try poll.vote(for: other.options[0].id)
        }
        #expect(poll.options.map(\.voteCount) == [0, 0])
    }

    @Test func archivingIsIndependentOfFinishing() throws {
        let poll = try Poll(
            title: "Куда?",
            optionTitles: ["А", "Б"]
        )
        poll.isArchived = true
        #expect(poll.status == .active)
        try poll.vote(for: poll.options[0].id)
        poll.finish()
        #expect(poll.isArchived)
        poll.isArchived = false
        #expect(poll.status == .finished)
        #expect(throws: Poll.VotingError.pollFinished) {
            try poll.vote(for: poll.options[1].id)
        }
        #expect(poll.results?.totalVoteCount == 1)
    }

    @Test func resultsUseTotalAndLeadingVoteCounts() throws {
        let poll = try Poll(
            title: "Куда?",
            optionTitles: ["А", "Б", "В"]
        )
        for index in [0, 1, 0, 1, 2] {
            try poll.vote(for: poll.options[index].id)
        }
        poll.finish()

        let results = try #require(poll.results)
        #expect(results.totalVoteCount == 5)
        #expect(results.options.map(\.id) == poll.options.map(\.id))
        #expect(results.options.map(\.voteShare) == [0.4, 0.4, 0.2])
        #expect(results.options.map(\.fractionOfLeadingVoteCount) == [1, 1, 0.5])
        #expect(results.options.map(\.isLeader) == [true, true, false])
    }

    @Test func emptyBallotBoxHasNoLeaders() throws {
        let poll = try Poll(
            title: "Куда?",
            optionTitles: ["А", "Б"]
        )
        poll.finish()
        let results = try #require(poll.results)
        #expect(results.totalVoteCount == 0)
        #expect(results.options.map(\.voteShare) == [0, 0])
        #expect(results.options.map(\.fractionOfLeadingVoteCount) == [0, 0])
        #expect(results.options.allSatisfy { !$0.isLeader })
    }
}
