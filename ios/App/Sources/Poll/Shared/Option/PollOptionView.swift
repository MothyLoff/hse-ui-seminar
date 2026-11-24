import PollarCore
import UIKit


final class PollOptionView: UIView {

    struct Style {
        let fillFraction: CGFloat

        static let regular = ranked(fraction: 0)
        static let prominent = ranked(fraction: 1)

        static func ranked(fraction: CGFloat) -> Self {
            Self(fillFraction: min(max(fraction, 0), 1))
        }

        private init(fillFraction: CGFloat) {
            self.fillFraction = fillFraction
        }
    }

    private let regular = PollOptionContentView()
    private let prominent = PollOptionContentView(
        foreground: .systemBackground,
        background: .label
    )
    private let fill = UIView()
    private let isFullscreen: Bool
    private var style: Style = .regular { didSet { setNeedsLayout() } }

    init(isFullscreen: Bool = false) {
        self.isFullscreen = isFullscreen
        super.init(frame: .zero)
        clipsToBounds = true
        fill.clipsToBounds = true
        addSubview(regular)
        addSubview(fill)
        fill.addSubview(prominent)
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(
        title: String,
        style: Style,
        trailing: Poll.Option.TrailingContent,
        isVotingChoice: Bool = false
    ) {
        self.style = style
        let usesVotingColors = isFullscreen && isVotingChoice
        regular.setColors(
            background: usesVotingColors
                ? .secondarySystemBackground : .tertiarySystemBackground,
            text: usesVotingColors ? .label : .secondaryLabel
        )
        let text = trailing.text
        for content in [regular, prominent] {
            content.configure(
                title: title,
                trailingText: text,
                showsPersonIcon: trailing.showsPersonIcon
            )
        }
        accessibilityLabel = title
        accessibilityValue = text
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: DesignComponent.Poll.Option.height)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        regular.frame = bounds
        fill.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width * style.fillFraction,
            height: bounds.height
        )
        prominent.frame = regular.bounds
    }

}
