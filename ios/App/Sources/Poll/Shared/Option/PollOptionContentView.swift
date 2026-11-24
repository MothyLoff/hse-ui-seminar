import UIKit


final class PollOptionContentView: UIView {

    private typealias Metrics = DesignComponent.Poll.Option
    private let bullet = UIView()
    private let titleLabel = UILabel()
    static func trailingInset(showsPersonIcon: Bool) -> CGFloat {
        showsPersonIcon ? Metrics.Padding.leading : Metrics.Padding.trailing
    }

    private let trailing = PollOptionTrailingView()
    private let row = UIStackView()
    private lazy var rowTrailing = row.trailingAnchor.constraint(equalTo: trailingAnchor)

    init(
        foreground: UIColor = .secondaryLabel,
        background: UIColor = .tertiarySystemBackground
    ) {
        super.init(frame: .zero)
        setColors(background: background, text: foreground)

        bullet.layer.cornerRadius = Metrics.Bullet.radius

        let baseFont = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.body,
            weight: .semibold
        )
        titleLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        titleLabel.adjustsFontForContentSizeCategory = true
        for view in [bullet, titleLabel, trailing] { row.addArrangedSubview(view) }
        row.alignment = .center
        row.spacing = Metrics.Bullet.spacing
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            bullet.widthAnchor.constraint(equalToConstant: Metrics.Bullet.size.width),
            bullet.heightAnchor.constraint(equalToConstant: Metrics.Bullet.size.height),
            row.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Padding.leading
            ),
            rowTrailing,
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func setColors(
        background: UIColor,
        text: UIColor
    ) {
        backgroundColor = background
        bullet.backgroundColor = text
        titleLabel.textColor = text
        trailing.setColor(text)
    }

    func configure(
        title: String,
        trailingText: String?,
        showsPersonIcon: Bool
    ) {
        titleLabel.text = title
        rowTrailing.constant = -Self.trailingInset(showsPersonIcon: showsPersonIcon)
        trailing.configure(text: trailingText, showsPersonIcon: showsPersonIcon)
    }

}
