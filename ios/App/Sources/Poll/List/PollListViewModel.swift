import PollarCore


final class PollListViewModel {

    private var polls: [Poll]
    var status: Poll.Status?
    var showsArchived = false

    init(polls: [Poll]) {
        self.polls = polls
    }

    var visiblePolls: [Poll] {
        polls.filter { poll in
            (showsArchived || !poll.isArchived) && (status == nil || poll.status == status)
        }
    }

    func poll(withID id: Poll.ID) -> Poll? {
        polls.first { $0.id == id }
    }

    func insert(_ poll: Poll) {
        polls.insert(poll, at: 0)
    }

    func toggleArchive(for poll: Poll) {
        poll.isArchived.toggle()
    }

}
