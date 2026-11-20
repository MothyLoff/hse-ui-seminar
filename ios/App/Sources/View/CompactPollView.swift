import PollarCore
import UIKit


final class CompactPollView: UIView {
    
    private lazy var titleLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textColor = .label
        return $0
    }(UILabel())
    
    private lazy var chevronView: UIImageView = {
        $0.tintColor = .label
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UIImageView(image: UIImage(systemName: "chevron.right")))
    
    private lazy var titleRow: UIStackView = {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 0
        return $0
    }(UIStackView(arrangedSubviews: [titleLabel, chevronView]))
    
    private lazy var descriptionLabel: UILabel = {
        $0.numberOfLines = 0
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())
    
    private lazy var headerStack: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = DesignComponent.Poll.Header.spacing
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView(arrangedSubviews: [titleRow, descriptionLabel]))
    
    private lazy var optionStack: UIStackView = {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = DesignComponent.Poll.OptionList.spacing
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIStackView())
    
    private lazy var optionContainer: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = DesignComponent.Poll.Option.radius
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    private lazy var optionContainerHeightConstraint = {
        optionContainer.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    private lazy var optionFadeView: OptionFadeView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        return $0
    }(OptionFadeView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with poll: Poll) {
        titleLabel.text = poll.title
        descriptionLabel.text = poll.description
        descriptionLabel.isHidden = poll.description == nil
        
        for view in optionStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for option in poll.options.sorted(by: { $0.voteCount > $1.voteCount }) {
            let view = PollOptionView()
            view.configure(with: option)
            optionStack.addArrangedSubview(view)
        }
        
        let topOptionCount = poll.options.count(where: { $0.isTopOption })
        let visibleCount = min(poll.options.count, topOptionCount + 1)
        let gapCount = max(0, visibleCount - 1)
        
        optionContainerHeightConstraint.constant =
            CGFloat(visibleCount) * DesignComponent.Poll.Option.height +
            CGFloat(gapCount) * optionStack.spacing
        
        optionFadeView.isHidden = topOptionCount == poll.options.count
    }
    
    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = DesignComponent.Poll.Background.cornerRadius
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        addSubview(headerStack)
        addSubview(optionContainer)
        optionContainer.addSubview(optionStack)
        optionContainer.addSubview(optionFadeView)
    }
    
    private func setupConstraints() {
        let horizontal = DesignComponent.Poll.Header.Padding.horizontal
        let vertical = DesignComponent.Poll.Header.Padding.vertical
        let optionPadding = DesignComponent.Poll.OptionList.padding

        NSLayoutConstraint.activate(
            [
                headerStack.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: vertical
                ),
                headerStack.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: horizontal
                ),
                headerStack.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -horizontal
                ),
                
                optionContainer.topAnchor.constraint(
                    equalTo: headerStack.bottomAnchor,
                    constant: vertical
                ),
                optionContainer.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: optionPadding
                ),
                optionContainer.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -optionPadding
                ),
                optionContainer.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -optionPadding
                ),
                optionContainerHeightConstraint,
                
                optionStack.topAnchor.constraint(
                    equalTo: optionContainer.topAnchor
                ),
                optionStack.leadingAnchor.constraint(
                    equalTo: optionContainer.leadingAnchor
                ),
                optionStack.trailingAnchor.constraint(
                    equalTo: optionContainer.trailingAnchor
                ),
                
                optionFadeView.bottomAnchor.constraint(
                    equalTo: optionContainer.bottomAnchor
                ),
                optionFadeView.leadingAnchor.constraint(
                    equalTo: optionContainer.leadingAnchor
                ),
                optionFadeView.trailingAnchor.constraint(
                    equalTo: optionContainer.trailingAnchor
                ),
                optionFadeView.heightAnchor.constraint(
                    equalToConstant: DesignComponent.Poll.Option.height
                )
            ]
        )
    }
    
    override func updateProperties() {
        super.updateProperties()
        
        let metrics = UIFontMetrics(forTextStyle: .body)
        
        let titleFont = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.title,
            weight: .semibold
        )
        let chevronFont = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.body,
            weight: .semibold
        )
        let descriptionFont = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.body,
            weight: .regular
        )
        
        titleLabel.font = metrics.scaledFont(
            for: titleFont,
            compatibleWith: traitCollection
        )
        
        chevronView.preferredSymbolConfiguration = .init(
            font: metrics.scaledFont(
                for: chevronFont,
                compatibleWith: traitCollection
            )
        )
        
        descriptionLabel.font = metrics.scaledFont(
            for: descriptionFont,
            compatibleWith: traitCollection
        )
    }
    
}
