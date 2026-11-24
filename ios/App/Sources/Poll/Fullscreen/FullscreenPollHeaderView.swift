import PollarCore
import UIKit


final class FullscreenPollHeaderView: UIView {

    let units = UISegmentedControl(items: ["Голоса", "Проценты"])
    let pollTitleView = PollTitleView(isFullscreen: true)
    let pollDescriptionView = PollDescriptionView(isFullscreen: true)
    private let pollTotalVoteCountView = PollOptionTrailingView()
    let resultControls = UIStackView()
    private lazy var descriptionTop = pollDescriptionView.topAnchor.constraint(
        equalTo: pollTitleView.bottomAnchor
    )
    private lazy var controlsTop = resultControls.topAnchor.constraint(
        equalTo: pollDescriptionView.bottomAnchor
    )

    override init(frame: CGRect) {
        super.init(frame: frame)
        pollTotalVoteCountView.setColor(.secondaryLabel)
        pollTotalVoteCountView.isAccessibilityElement = true
        pollTotalVoteCountView.accessibilityTraits = .staticText
        pollTotalVoteCountView.accessibilityLabel = "Всего голосов"
        units.selectedSegmentIndex = 0
        units.accessibilityLabel = "Единицы результата"
        units.setContentCompressionResistancePriority(.required, for: .horizontal)
        resultControls.addArrangedSubview(units)
        resultControls.addArrangedSubview(pollTotalVoteCountView)
        resultControls.distribution = .equalSpacing
        resultControls.spacing = 12

        for child in [pollTitleView, pollDescriptionView, resultControls] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
        }
        typealias Metrics = DesignComponent.Poll
        let safe = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            pollTitleView.topAnchor.constraint(equalTo: topAnchor),
            pollTitleView.leadingAnchor.constraint(
                equalTo: safe.leadingAnchor,
                constant: Metrics.Header.Padding.horizontal
            ),
            pollTitleView.trailingAnchor.constraint(
                equalTo: safe.trailingAnchor,
                constant: -Metrics.Header.Padding.horizontal
            ),
            descriptionTop,
            pollDescriptionView.leadingAnchor.constraint(equalTo: pollTitleView.leadingAnchor),
            pollDescriptionView.trailingAnchor.constraint(
                equalTo: pollTitleView.trailingAnchor
            ),
            controlsTop,
            resultControls.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.OptionList.padding
            ),
            resultControls.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant:
                    -(Metrics.OptionList.padding
                    + PollOptionContentView.trailingInset(showsPersonIcon: true))
            ),
            bottomAnchor.constraint(equalTo: resultControls.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(
        poll: Poll,
        totalVoteCount: Int?
    ) {
        let isFinished = totalVoteCount != nil
        pollTitleView.configure(title: poll.title, isArchived: poll.isArchived)
        pollDescriptionView.configure(description: poll.description)
        descriptionTop.constant = pollDescriptionView.spacingAbove
        controlsTop.constant = isFinished ? 16 : 0
        for control in resultControls.arrangedSubviews { control.isHidden = !isFinished }
        let count = totalVoteCount.map(String.init)
        pollTotalVoteCountView.configure(text: count, showsPersonIcon: isFinished)
        pollTotalVoteCountView.accessibilityValue = count
    }

    override func updateProperties() {
        super.updateProperties()
        let largeText = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        resultControls.axis = largeText ? .vertical : .horizontal
        resultControls.alignment = largeText ? .leading : .center
    }

}
