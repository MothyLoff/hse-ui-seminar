import PollarCore


struct PollDraftViewModel {

    var title = ""
    var description = ""
    var optionTitles: [String] = []

    var canCreate: Bool {
        !title.isEmpty && optionTitles.count >= 2
    }

    func makePoll() throws(Poll.CreationError) -> Poll {
        try Poll(
            title: title,
            description: description,
            optionTitles: optionTitles
        )
    }

}
