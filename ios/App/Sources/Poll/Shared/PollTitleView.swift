import UIKit


final class PollTitleView: UILabel {

    init(isFullscreen: Bool = false) {
        super.init(frame: .zero)
        if isFullscreen {
            let baseFont = UIFont.systemFont(ofSize: 34, weight: .bold)
            font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: baseFont)
            numberOfLines = 0
            accessibilityTraits.insert(.header)
        } else {
            let baseFont = UIFont.systemFont(
                ofSize: DesignComponent.DefaultFontSize.title,
                weight: .semibold
            )
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
            numberOfLines = 2
            lineBreakMode = .byTruncatingTail
            setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
        adjustsFontForContentSizeCategory = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(
        title: String,
        isArchived: Bool
    ) {
        text = title
        textColor = isArchived ? .secondaryLabel : .label
    }

}
