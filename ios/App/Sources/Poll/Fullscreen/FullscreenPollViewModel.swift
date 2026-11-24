import PollarCore


final class FullscreenPollViewModel {

    let poll: Poll
    private(set) var selectedOptionID: Poll.Option.ID?
    private(set) var isHandingOff = false
    private var nextParticipantRequested = false
    var sortsByPopularity = true
    var showsPercentages = false

    init(poll: Poll) {
        self.poll = poll
    }

    func select(_ id: Poll.Option.ID) {
        guard poll.status == .active, !isHandingOff else {
            return
        }
        selectedOptionID = id
    }

    func submitVote() -> Bool {
        guard !isHandingOff, let selectedOptionID else {
            return false
        }
        do {
            try poll.vote(for: selectedOptionID)
            isHandingOff = true
            return true
        } catch {
            return false
        }
    }

    func beginNextParticipant() -> Bool {
        guard isHandingOff else {
            return false
        }
        guard selectedOptionID == nil else {
            nextParticipantRequested = true
            return false
        }
        isHandingOff = false
        return true
    }

    func completeConfirmation() -> Bool {
        selectedOptionID = nil
        guard nextParticipantRequested else {
            return false
        }
        nextParticipantRequested = false
        return beginNextParticipant()
    }

    func finish() {
        guard !isHandingOff else {
            return
        }
        poll.finish()
        selectedOptionID = nil
    }

    func orderedOptions(in results: Poll.Results) -> [Poll.OptionResult] {
        guard sortsByPopularity else { return results.options }
        return results.options.sorted { $0.option.voteCount > $1.option.voteCount }
    }

}
