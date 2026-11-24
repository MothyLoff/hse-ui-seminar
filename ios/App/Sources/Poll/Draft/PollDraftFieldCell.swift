import UIKit


final class PollDraftFieldCell: UITableViewCell {

    let field = UITextField()

    init(placeholder: String) {
        super.init(style: .default, reuseIdentifier: nil)
        selectionStyle = .none
        field.placeholder = placeholder
        field.accessibilityLabel = placeholder
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.clearButtonMode = .whileEditing
        field.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(field)
        let margins = contentView.layoutMarginsGuide
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            field.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            field.topAnchor.constraint(equalTo: margins.topAnchor),
            field.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    var text: String {
        (field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
