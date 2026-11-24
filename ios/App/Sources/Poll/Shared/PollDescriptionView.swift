import UIKit


final class PollDescriptionView: UILabel {

    var spacingAbove: CGFloat { isHidden ? 0 : DesignComponent.Poll.Header.spacing }

    init(isFullscreen: Bool = false) {
        super.init(frame: .zero)
        if isFullscreen {
            font = .preferredFont(forTextStyle: .body)
        } else {
            let baseFont = UIFont.systemFont(
                ofSize: DesignComponent.DefaultFontSize.body,
                weight: .regular
            )
            font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        }
        adjustsFontForContentSizeCategory = true
        numberOfLines = 0
        textColor = .secondaryLabel
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(description: String?) {
        text = description
        isHidden = description?.isEmpty ?? true
    }

}
