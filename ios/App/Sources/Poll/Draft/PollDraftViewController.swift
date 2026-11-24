import PollarCore
import UIKit


final class PollDraftViewController: UITableViewController, UITextFieldDelegate {

    var onCreate: ((Poll) -> Void)?
    private var viewModel = PollDraftViewModel()
    private let pollTitle = PollDraftFieldCell(placeholder: "Вопрос")
    private let pollDescription = PollDraftFieldCell(placeholder: "Описание (необязательно)")
    private var options = [
        PollDraftFieldCell(placeholder: "Вариант 1"),
        PollDraftFieldCell(placeholder: "Вариант 2"),
    ]

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новое голосование"
        navigationItem.largeTitleDisplayMode = .never
        if #available(iOS 27.2, *) {
            navigationItem.titleAlignment = .center
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        let create = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in self?.createPoll() }
        )
        create.style = .prominent
        create.accessibilityLabel = "Создать голосование"
        navigationItem.rightBarButtonItem = create
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        for cell in [pollTitle, pollDescription] + options { configureInput(cell) }
        options.last?.field.returnKeyType = .done
        updateCreateButton()
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        section == 0 ? 2 : options.count
    }

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        section == 1 ? "Варианты ответа" : nil
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.section == 0 { return indexPath.row == 0 ? pollTitle : pollDescription }
        return options[indexPath.row]
    }

    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? PollDraftFieldCell
        cell?.field.becomeFirstResponder()
    }

    private func configureInput(_ cell: PollDraftFieldCell) {
        cell.field.delegate = self
        cell.field.returnKeyType = .next
        cell.field.addTarget(self, action: #selector(inputChanged(_:)), for: .editingChanged)
    }

    @objc private func inputChanged(_ field: UITextField) {
        if options.contains(where: { $0.field === field }) {
            updateOptionRows(keeping: field)
        }
        updateCreateButton()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard options.contains(where: { $0.field === textField }) else {
            return
        }
        Task { @MainActor [weak self] in self?.updateOptionRows() }
    }

    private func updateOptionRows(keeping editingField: UITextField? = nil) {
        var rows = options
        let needsBlank = rows.last?.text.isEmpty == false
        if needsBlank {
            let blank = PollDraftFieldCell(placeholder: "Вариант")
            configureInput(blank)
            rows.append(blank)
        }

        var removed: [IndexPath] = []
        for index in options.indices.reversed() where rows.count > 2 {
            let cell = options[index]
            if cell.text.isEmpty && cell.field !== editingField && !cell.field.isFirstResponder
                && cell !== rows.last
            {
                rows.remove(at: index)
                removed.append(IndexPath(row: index, section: 1))
            }
        }
        guard needsBlank || !removed.isEmpty else {
            return
        }
        options = rows
        for (index, cell) in rows.enumerated() {
            let label = "Вариант \(index + 1)"
            cell.field.placeholder = label
            cell.field.accessibilityLabel = label
            let key: UIReturnKeyType = index == rows.count - 1 ? .done : .next
            if cell.field.returnKeyType != key {
                cell.field.returnKeyType = key
                if cell.field.isFirstResponder { cell.field.reloadInputViews() }
            }
        }
        tableView.performBatchUpdates {
            tableView.deleteRows(at: removed, with: .fade)
            if needsBlank {
                tableView.insertRows(
                    at: [IndexPath(row: rows.count - 1, section: 1)],
                    with: .fade
                )
            }
        }
    }

    private func focus(
        _ cell: PollDraftFieldCell,
        at indexPath: IndexPath
    ) {
        tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        tableView.layoutIfNeeded()
        cell.field.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let cells = [pollTitle, pollDescription] + options
        guard let index = cells.firstIndex(where: { $0.field === textField }),
            index + 1 < cells.count
        else {
            textField.resignFirstResponder()
            return false
        }
        let next = index + 1
        let path =
            next < 2 ? IndexPath(row: next, section: 0) : IndexPath(row: next - 2, section: 1)
        focus(cells[next], at: path)
        return false
    }

    private func updateCreateButton() {
        viewModel.title = pollTitle.text
        viewModel.description = pollDescription.text
        viewModel.optionTitles = options.map(\.text).filter { !$0.isEmpty }
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.canCreate
    }

    private func createPoll() {
        guard let poll = try? viewModel.makePoll() else {
            return
        }
        onCreate?(poll)
    }

}
