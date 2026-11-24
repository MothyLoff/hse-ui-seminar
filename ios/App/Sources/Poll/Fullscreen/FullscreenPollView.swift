import PollarCore
import UIKit


final class FullscreenPollView: UIView {

    let bottomButton = UIButton(type: .system)
    let header = FullscreenPollHeaderView()
    let optionStack = UIStackView()

    private let scroll = UIScrollView()
    private let handoff = UIVisualEffectView(effect: nil)
    private let handoffBackground = UIView()
    private let handoffBlur = UIBlurEffect(style: .systemUltraThinMaterial)
    private var handoffAnimator: UIViewPropertyAnimator?
    private let check = UIImageView(image: UIImage(systemName: "checkmark.circle"))

    private let message = UIStackView()
    private let headerBackground = UIView()

    private let headerFade = FullscreenPollFadeView()
    private let buttonFade = FullscreenPollFadeView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        optionStack.axis = .vertical
        optionStack.spacing = DesignComponent.Poll.OptionList.spacing

        scroll.clipsToBounds = false
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        optionStack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(optionStack)

        headerBackground.backgroundColor = backgroundColor
        headerBackground.isUserInteractionEnabled = false
        headerFade.isUserInteractionEnabled = false
        buttonFade.isUserInteractionEnabled = false
        if let gradient = headerFade.layer as? CAGradientLayer {
            gradient.startPoint = CGPoint(x: 0.5, y: 1)
            gradient.endPoint = CGPoint(x: 0.5, y: 0)
        }
        configureButton(bottomButton, title: "Проголосовать")
        for child in [
            scroll, headerBackground, headerFade, header, buttonFade, handoff, bottomButton,
        ] {
            child.translatesAutoresizingMaskIntoConstraints = false
            addSubview(child)
        }

        check.preferredSymbolConfiguration = .init(pointSize: 84, weight: .light)
        check.tintColor = .white
        check.layer.shadowColor = UIColor.black.cgColor
        check.layer.shadowOffset = .zero
        check.layer.shadowRadius = 1
        check.contentMode = .center
        check.addSymbolEffect(.drawOff.byLayer, animated: false)
        let confirmation = UILabel()
        confirmation.text = "Голос учтён"
        confirmation.font = UIFontMetrics(forTextStyle: .title1).scaledFont(
            for: .systemFont(ofSize: 28, weight: .bold)
        )
        confirmation.textAlignment = .center
        confirmation.numberOfLines = 0
        confirmation.adjustsFontForContentSizeCategory = true
        message.addArrangedSubview(check)
        message.addArrangedSubview(confirmation)
        message.isHidden = true
        message.axis = .vertical
        message.spacing = 16
        message.translatesAutoresizingMaskIntoConstraints = false
        handoffBackground.frame = handoff.contentView.bounds
        handoffBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        handoffBackground.backgroundColor = .systemBackground
        handoffBackground.isUserInteractionEnabled = false
        handoffBackground.alpha = 0
        handoff.contentView.addSubview(handoffBackground)
        handoff.contentView.addSubview(message)
        handoff.isHidden = true

        typealias Metrics = DesignComponent.Poll
        let safe = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(
                equalTo: safe.topAnchor,
                constant: Metrics.Header.Padding.vertical
            ),
            header.leadingAnchor.constraint(equalTo: leadingAnchor),
            header.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.topAnchor.constraint(
                equalTo: header.bottomAnchor,
                constant: Metrics.Header.Padding.vertical
            ),
            scroll.leadingAnchor.constraint(equalTo: leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
            optionStack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            optionStack.leadingAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.leadingAnchor,
                constant: Metrics.OptionList.padding
            ),
            optionStack.trailingAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.trailingAnchor,
                constant: -Metrics.OptionList.padding
            ),
            optionStack.bottomAnchor.constraint(
                equalTo: scroll.contentLayoutGuide.bottomAnchor
            ),
            scroll.contentLayoutGuide.widthAnchor.constraint(
                equalTo: scroll.frameLayoutGuide.widthAnchor
            ),
            headerFade.heightAnchor.constraint(equalToConstant: 40),
            headerFade.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerFade.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerFade.bottomAnchor.constraint(equalTo: scroll.topAnchor),
            headerBackground.heightAnchor.constraint(equalTo: heightAnchor),
            headerBackground.bottomAnchor.constraint(equalTo: headerFade.topAnchor),
            headerBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonFade.topAnchor.constraint(equalTo: bottomButton.topAnchor),
            buttonFade.bottomAnchor.constraint(equalTo: bottomAnchor),
            buttonFade.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonFade.trailingAnchor.constraint(equalTo: trailingAnchor),
            handoff.topAnchor.constraint(equalTo: topAnchor),
            handoff.bottomAnchor.constraint(equalTo: bottomAnchor),
            handoff.leadingAnchor.constraint(equalTo: leadingAnchor),
            handoff.trailingAnchor.constraint(equalTo: trailingAnchor),
            message.centerYAnchor.constraint(equalTo: safe.centerYAnchor),
            message.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            message.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            bottomButton.heightAnchor.constraint(equalToConstant: 64),
            bottomButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            bottomButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            bottomButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func updateProperties() {
        super.updateProperties()
        check.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.8 : 0
    }

    func configure(
        poll: Poll,
        totalVoteCount: Int?
    ) {
        let isFinished = totalVoteCount != nil
        header.configure(poll: poll, totalVoteCount: totalVoteCount)
        bottomButton.isHidden = isFinished
        buttonFade.isHidden = isFinished
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let coveredHeight =
            bottomButton.isHidden
            ? safeAreaInsets.bottom : bounds.maxY - bottomButton.frame.minY
        let inset = coveredHeight + DesignComponent.Poll.OptionList.padding
        if scroll.contentInset.bottom != inset {
            scroll.contentInset.bottom = inset
            scroll.verticalScrollIndicatorInsets.bottom = inset
        }
    }

    func showHandoff(
        _ visible: Bool,
        onPresented: ((
    ) -> Void)? = nil) {
        guard visible == message.isHidden else {
            return
        }
        let animated = !UIAccessibility.isReduceMotionEnabled
        let entrance = DispatchGroup()
        handoff.isHidden = false
        message.isHidden = !visible
        header.accessibilityElementsHidden = true
        scroll.accessibilityElementsHidden = true
        if visible {
            if animated && window != nil {
                entrance.enter()
                check.removeSymbolEffect(ofType: .drawOff, options: .speed(0.65 / 0.4)) { _ in
                    entrance.leave()
                }
            } else {
                check.removeSymbolEffect(ofType: .drawOff, animated: false)
            }
        } else {
            check.addSymbolEffect(.drawOff.byLayer, animated: false)
        }
        bottomButton.configuration?.title = visible ? "Следующий участник" : "Проголосовать"

        if !animated {
            handoffAnimator?.stopAnimation(true)
            finishHandoffTransition(visible: visible)
        } else if let animator = handoffAnimator {
            animator.isReversed.toggle()
        } else {
            let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
                [weak self] in
                guard let self else {
                    return
                }
                handoff.effect = visible ? handoffBlur : nil
                handoffBackground.alpha = visible ? 1 : 0
            }
            entrance.enter()
            animator.addCompletion { [weak self] position in
                self?.finishHandoffTransition(visible: position == .end ? visible : !visible)
                entrance.leave()
            }
            handoffAnimator = animator
            animator.startAnimation()
        }
        if visible {
            UIAccessibility.post(notification: .screenChanged, argument: bottomButton)
        }
        if let onPresented { entrance.notify(queue: .main, execute: onPresented) }
    }

    private func finishHandoffTransition(visible: Bool) {
        handoffAnimator = nil
        handoff.effect = visible ? handoffBlur : nil
        handoffBackground.alpha = visible ? 1 : 0
        handoff.isHidden = !visible
        header.accessibilityElementsHidden = visible
        scroll.accessibilityElementsHidden = visible
    }

    private func configureButton(
        _ button: UIButton,
        title: String
    ) {
        var config = UIButton.Configuration.prominentGlass()
        config.title = title
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.baseBackgroundColor = .label
        config.baseForegroundColor = .systemBackground
        button.configuration = config
        button.configurationUpdateHandler = { button in
            let traits = button.traitCollection
            let font = DesignComponent.bodySemibold(compatibleWith: traits)
            let textColor = UIColor.systemBackground.resolvedColor(with: traits)
            let isEnabled = button.isEnabled
            button.configuration?.titleTextAttributesTransformer =
                UIConfigurationTextAttributesTransformer { attributes in
                    var attributes = attributes
                    attributes.font = font
                    if isEnabled {
                        attributes.foregroundColor = textColor
                    }
                    return attributes
                }
        }
    }

}
