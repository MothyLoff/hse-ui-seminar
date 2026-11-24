import PollarCore
import UIKit


final class CompactPollView: UIView {

    private let pollTitleView = PollTitleView()
    private let pollDescriptionView = PollDescriptionView()
    private let badge = PollBadgeView()
    private let optionContainer = UIView()
    private lazy var descriptionTop = pollDescriptionView.topAnchor.constraint(
        equalTo: pollTitleView.bottomAnchor
    )
    private lazy var visibleHeight = optionContainer.heightAnchor.constraint(
        equalToConstant: 0
    )
    private let options = UIStackView()
    private let fade = OptionFadeView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        typealias Metrics = DesignComponent.Poll
        let radius = Metrics.Background.cornerRadius
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = radius

        options.axis = .vertical
        options.spacing = Metrics.OptionList.spacing
        optionContainer.layer.cornerRadius = Metrics.Option.radius
        optionContainer.clipsToBounds = true
        optionContainer.addSubview(options)
        optionContainer.addSubview(fade)
        fade.isUserInteractionEnabled = false

        for child in [pollTitleView, pollDescriptionView, badge, optionContainer] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
        }
        options.translatesAutoresizingMaskIntoConstraints = false
        fade.translatesAutoresizingMaskIntoConstraints = false

        let cornerInset = UILayoutGuide()
        addLayoutGuide(cornerInset)
        NSLayoutConstraint.activate([
            badge.centerYAnchor.constraint(equalTo: topAnchor, constant: radius),
            cornerInset.topAnchor.constraint(equalTo: topAnchor),
            cornerInset.bottomAnchor.constraint(equalTo: badge.topAnchor),
            cornerInset.trailingAnchor.constraint(equalTo: trailingAnchor),
            cornerInset.widthAnchor.constraint(equalTo: cornerInset.heightAnchor),
            badge.trailingAnchor.constraint(equalTo: cornerInset.leadingAnchor),
            pollTitleView.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Metrics.Header.Padding.vertical
            ),
            pollTitleView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Header.Padding.horizontal
            ),
            pollTitleView.trailingAnchor.constraint(
                lessThanOrEqualTo: badge.leadingAnchor,
                constant: -Metrics.Header.spacing
            ),
            descriptionTop,
            pollDescriptionView.leadingAnchor.constraint(equalTo: pollTitleView.leadingAnchor),
            pollDescriptionView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metrics.Header.Padding.horizontal
            ),
            optionContainer.topAnchor.constraint(
                equalTo: pollDescriptionView.bottomAnchor,
                constant: Metrics.Header.Padding.vertical
            ),
            optionContainer.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.OptionList.padding
            ),
            optionContainer.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metrics.OptionList.padding
            ),
            optionContainer.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metrics.OptionList.padding
            ),
            visibleHeight,
            options.topAnchor.constraint(equalTo: optionContainer.topAnchor),
            options.leadingAnchor.constraint(equalTo: optionContainer.leadingAnchor),
            options.trailingAnchor.constraint(equalTo: optionContainer.trailingAnchor),
            fade.leadingAnchor.constraint(equalTo: optionContainer.leadingAnchor),
            fade.trailingAnchor.constraint(equalTo: optionContainer.trailingAnchor),
            fade.bottomAnchor.constraint(equalTo: optionContainer.bottomAnchor),
            fade.heightAnchor.constraint(equalToConstant: Metrics.Option.height),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var statusDescription: String? { badge.accessibilityLabel }

    func configure(with poll: Poll) {
        pollTitleView.configure(title: poll.title, isArchived: poll.isArchived)
        pollDescriptionView.configure(description: poll.description)
        descriptionTop.constant = pollDescriptionView.spacingAbove
        badge.configure(status: poll.status, isArchived: poll.isArchived)
        options.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let visibleCount: Int
        if let results = poll.results {
            let ordered = results.options.sorted { $0.option.voteCount > $1.option.voteCount }
            visibleCount = min(ordered.count, ordered.prefix(while: { $0.isLeader }).count + 1)
            for result in ordered {
                addOption(
                    title: result.option.title,
                    style: result.isLeader ? .prominent : .regular,
                    trailing: .percentage(result.voteShare)
                )
            }
        } else {
            visibleCount = min(2, poll.options.count)
            for option in poll.options {
                addOption(title: option.title, style: .regular, trailing: .none)
            }
        }
        visibleHeight.constant =
            CGFloat(visibleCount) * DesignComponent.Poll.Option.height
            + CGFloat(max(0, visibleCount - 1)) * options.spacing
        fade.isHidden = visibleCount == options.arrangedSubviews.count
        for (index, row) in options.arrangedSubviews.enumerated() {
            row.isAccessibilityElement = index < visibleCount
            row.accessibilityElementsHidden = index >= visibleCount
        }
    }

    private func addOption(
        title: String,
        style: PollOptionView.Style,
        trailing: Poll.Option.TrailingContent
    ) {
        let row = PollOptionView()
        row.configure(title: title, style: style, trailing: trailing)
        options.addArrangedSubview(row)
    }

}
