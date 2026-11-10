//  Voew.swift, created by Timowa on 10.11.2026

import Foundation
import Observation


@Observable
final class Poll: Identifiable {

    var title: String
    var description: String?

    private(set) var options: [PollOption] = []
    private(set) var selectedOption: PollOption?


    init(title: String, description: String? = nil, options: [PollOption]) {
        self.title = title
        self.description = description
        self.options = options
        for option in options {
            option.poll = self
        }
    }

    func addOption(title: String, voteCount: Int) {
        let p = PollOption(poll: self, title: title, votes: voteCount)
        options.append(p)
    }

    func vote(for option: PollOption) {
        guard options.contains(where: { $0 === option }), selectedOption !== option else { return }

        if let selectedOption {
            selectedOption.votes -= 1
        }
        option.votes += 1
        selectedOption = option
    }

}


extension Poll {

    var voteCount: Int { options.map(\.votes).reduce(0, +) }

    var maxVoteCount: Int? { options.map(\.votes).max() }

}
