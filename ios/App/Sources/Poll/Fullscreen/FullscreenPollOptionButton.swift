import PollarCore
import UIKit


final class FullscreenPollOptionButton: UIButton {

    let optionID: Poll.Option.ID
    private let title: String
    private let row = PollOptionView(isFullscreen: true)

    init(option: Poll.Option) {
        optionID = option.id
        title = option.title
        super.init(frame: .zero)
        row.isUserInteractionEnabled = false
        row.isAccessibilityElement = false
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        accessibilityLabel = option.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func showChoice(selected: Bool) {
        isUserInteractionEnabled = true
        accessibilityTraits = selected ? [.button, .selected] : .button
        accessibilityValue = nil
        row.configure(
            title: title,
            style: selected ? .prominent : .regular,
            trailing: .none,
            isVotingChoice: true
        )
    }

    func showResult(
        _ result: Poll.OptionResult,
        trailing: Poll.Option.TrailingContent
    ) {
        isUserInteractionEnabled = false
        accessibilityTraits = .staticText
        accessibilityValue = trailing.text
        row.configure(
            title: title,
            style: .ranked(fraction: result.fractionOfLeadingVoteCount),
            trailing: trailing
        )
    }

}
