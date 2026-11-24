import Foundation
import Observation


@Observable
public final class Poll: Identifiable {
    
    public let id = UUID()
    public let title: String
    public let description: String?
    public private(set) var options: [Option]
    public private(set) var status: Status = .active
    public var isArchived = false

    public init(
        title: String,
        description: String? = nil,
        optionTitles: [String]
    ) throws(CreationError) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw .emptyTitle
        }
        guard optionTitles.count >= 2 else {
            throw .tooFewOptions
        }

        let titles = optionTitles.map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard !titles.contains(where: \.isEmpty) else {
            throw .emptyOptionTitle
        }

        self.title = title
        let description = description?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.description = description == "" ? nil : description
        self.options = titles.map(Option.init(title:))
    }

    public func vote(for optionID: Option.ID) throws(VotingError) {
        guard status == .active else {
            throw .pollFinished
        }
        guard let index = options.firstIndex(where: { $0.id == optionID }) else {
            throw .unknownOption
        }

        options[index].voteCount += 1
    }

    public func finish() {
        status = .finished
    }

}
