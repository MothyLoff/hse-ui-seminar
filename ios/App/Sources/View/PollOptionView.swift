import PollarCore
import UIKit


final class PollOptionView: UIView {
    
    private lazy var bulletView: UIView = {
        let circle = UIView()
        circle.layer.cornerRadius = DesignComponent.Poll.Option.Bullet.radius
        circle.backgroundColor = .label
        circle.translatesAutoresizingMaskIntoConstraints = false
        return circle
    }()
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "Option"
        label.numberOfLines = 1
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var percentageView: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.numberOfLines = 1
        label.textColor = .label
        label.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with option: Poll.Option) {
        titleView.text = option.title
        percentageView.text = String(option.votePercentage) + "%"
        
        backgroundColor = option.isTopOption
            ? .label
            : .tertiarySystemBackground
        
        let fontColor: UIColor = option.isTopOption
            ? .systemBackground
            : .secondaryLabel
        
        bulletView.backgroundColor = fontColor
        titleView.textColor = fontColor
        percentageView.textColor = fontColor
    }
    
    private func setupView() {
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = DesignComponent.Poll.Option.radius
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        addSubview(bulletView)
        addSubview(titleView)
        addSubview(percentageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                heightAnchor.constraint(
                    equalToConstant: DesignComponent.Poll.Option.height
                ),
                
                bulletView.widthAnchor.constraint(
                    equalToConstant: DesignComponent.Poll.Option.Bullet.size.width
                ),
                bulletView.heightAnchor.constraint(
                    equalToConstant: DesignComponent.Poll.Option.Bullet.size.height
                ),
                bulletView.centerYAnchor.constraint(
                    equalTo: centerYAnchor
                ),
                bulletView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: DesignComponent.Poll.Option.Padding.leading
                ),
                
                titleView.centerYAnchor.constraint(
                    equalTo: centerYAnchor
                ),
                titleView.leadingAnchor.constraint(
                    equalTo: bulletView.trailingAnchor,
                    constant: DesignComponent.Poll.Option.Bullet.spacing
                ),
                
                titleView.trailingAnchor.constraint(
                    lessThanOrEqualTo: percentageView.leadingAnchor,
                ),
                
                percentageView.centerYAnchor.constraint(
                    equalTo: centerYAnchor
                ),
                percentageView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -DesignComponent.Poll.Option.Padding.trailing
                )
                
            ]
        )
    }
    
    override func updateProperties() {
        super.updateProperties()
        
        let metrics = UIFontMetrics(forTextStyle: .body)
        
        let font = UIFont.systemFont(
            ofSize: DesignComponent.DefaultFontSize.body,
            weight: .semibold
        )
        
        titleView.font = metrics.scaledFont(
            for: font,
            compatibleWith: traitCollection
        )
        
        percentageView.font = metrics.scaledFont(
            for: font,
            compatibleWith: traitCollection
        )
    }
    
}
