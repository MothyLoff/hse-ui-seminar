import PollarCore
import UIKit


final class PollBadgeView: UIStackView {

    private let archiveIcon = UIImageView(image: UIImage(systemName: "archivebox.fill"))
    private let statusIcon = UIImageView()
    private let activeDot = UIView()

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        spacing = 6
        archiveIcon.tintColor = .systemRed
        archiveIcon.preferredSymbolConfiguration = .init(pointSize: 17, weight: .regular)
        archiveIcon.setContentHuggingPriority(.required, for: .horizontal)
        addArrangedSubview(archiveIcon)
        addArrangedSubview(statusIcon)
        statusIcon.contentMode = .center
        statusIcon.preferredSymbolConfiguration = .init(pointSize: 15, weight: .semibold)
        statusIcon.tintColor = .secondaryLabel
        let dotSize = DesignComponent.Poll.Badge.activeDotSize
        activeDot.layer.cornerRadius = dotSize.height / 2
        activeDot.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.addSubview(activeDot)
        NSLayoutConstraint.activate([
            activeDot.widthAnchor.constraint(equalToConstant: dotSize.width),
            activeDot.heightAnchor.constraint(equalToConstant: dotSize.height),
            activeDot.centerXAnchor.constraint(equalTo: statusIcon.centerXAnchor),
            activeDot.centerYAnchor.constraint(equalTo: statusIcon.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 20),
            statusIcon.heightAnchor.constraint(equalTo: heightAnchor),
            heightAnchor.constraint(equalToConstant: 20),
        ])
        isAccessibilityElement = true
        accessibilityTraits = .staticText
    }

    @available(*, unavailable)
    required init(coder: NSCoder) { super.init(coder: coder) }

    func configure(
        status: Poll.Status,
        isArchived: Bool
    ) {
        activeDot.backgroundColor = isArchived ? .secondaryLabel : .systemGreen
        activeDot.isHidden = status == .finished
        statusIcon.image =
            status == .finished ? UIImage(systemName: "flag.pattern.checkered") : nil
        archiveIcon.isHidden = !isArchived
        let label = status == .active ? "Активно" : "Завершено"
        accessibilityLabel = isArchived ? "\(label), в архиве" : label
    }

}
