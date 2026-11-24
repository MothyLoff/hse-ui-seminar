import UIKit


final class PollOptionTrailingView: UIStackView {

    private let icon = UIImageView(image: UIImage(systemName: "person.fill"))
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let size = DesignComponent.Poll.Option.Bullet.size
        icon.preferredSymbolConfiguration = .init(
            pointSize: size.height,
            weight: .regular,
            scale: .medium
        )
        icon.contentMode = .center
        icon.isAccessibilityElement = false
        let width = icon.widthAnchor.constraint(equalToConstant: size.width)
        width.priority = .defaultHigh
        NSLayoutConstraint.activate([
            width, icon.heightAnchor.constraint(equalToConstant: size.height),
        ])

        let font = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.body,
            weight: .semibold
        )
        label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        addArrangedSubview(icon)
        addArrangedSubview(label)
        alignment = .center
        spacing = 2
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { super.init(coder: coder) }

    func setColor(_ color: UIColor) {
        icon.tintColor = color
        label.textColor = color
    }

    func configure(
        text: String?,
        showsPersonIcon: Bool
    ) {
        label.text = text
        icon.isHidden = !showsPersonIcon
        isHidden = text == nil
    }

}
