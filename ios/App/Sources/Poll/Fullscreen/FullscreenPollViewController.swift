import PollarCore
import UIKit


final class FullscreenPollViewController: UIViewController {

    var onPollChange: (() -> Void)?
    private let viewModel: FullscreenPollViewModel
    private var buttons: [Poll.Option.ID: FullscreenPollOptionButton] = [:]
    private let screen = FullscreenPollView()

    init(viewModel: FullscreenPollViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() { view = screen }

    override func viewDidLoad() {
        super.viewDidLoad()

        for option in viewModel.poll.options {
            let button = FullscreenPollOptionButton(option: option)
            buttons[option.id] = button
            button.addTarget(self, action: #selector(selectOption(_:)), for: .touchUpInside)
            screen.optionStack.addArrangedSubview(button)
        }

        screen.bottomButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        screen.header.units.addTarget(self, action: #selector(changeUnits), for: .valueChanged)
        refresh()
    }

    @objc private func selectOption(_ sender: FullscreenPollOptionButton) {
        viewModel.select(sender.optionID)
        refresh()
    }

    @objc private func advance() {
        if viewModel.isHandingOff {
            if viewModel.beginNextParticipant() {
                screen.showHandoff(false)
            }
        } else if viewModel.submitVote() {
            onPollChange?()
            screen.showHandoff(true) { [weak self] in
                guard let self else {
                    return
                }
                if viewModel.completeConfirmation() {
                    screen.showHandoff(false)
                }
                refresh()
            }
        }
        refresh()
    }

    @objc private func confirmFinish() {
        guard viewModel.poll.status == .active, !viewModel.isHandingOff else {
            return
        }
        let dialog = UIAlertController(
            title: "Завершить голосование?",
            message: "После завершения вы увидите результаты.",
            preferredStyle: .actionSheet
        )
        dialog.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        dialog.addAction(
            UIAlertAction(title: "Завершить", style: .destructive) { [weak self] _ in
                self?.viewModel.finish()
                self?.onPollChange?()
                self?.refresh()
            }
        )
        dialog.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItem
        dialog.preferredTransition = .zoom(sourceBarButtonItemProvider: { [weak self] _ in
            self?.navigationItem.rightBarButtonItem
        })
        present(dialog, animated: true)
    }

    @objc private func changeUnits() {
        viewModel.showsPercentages = screen.header.units.selectedSegmentIndex == 1
        refresh()
    }

    private func refresh() {
        let poll = viewModel.poll
        let results = poll.results

        let finished = results != nil
        title = finished ? "Результаты" : "Голосование"
        screen.configure(poll: poll, totalVoteCount: results?.totalVoteCount)
        screen.bottomButton.isEnabled =
            viewModel.selectedOptionID != nil || viewModel.isHandingOff

        if finished {
            let choices = [(true, "По популярности"), (false, "По порядку добавления")]
            let actions = choices.map { byPopularity, title in
                UIAction(
                    title: title,
                    state: viewModel.sortsByPopularity == byPopularity ? .on : .off
                ) { [weak self] _ in
                    self?.viewModel.sortsByPopularity = byPopularity
                    self?.refresh()
                }
            }
            let sort = UIBarButtonItem(
                image: UIImage(systemName: "line.3.horizontal.decrease"),
                menu: UIMenu(title: "Сортировка", children: actions)
            )
            sort.accessibilityLabel = "Сортировка"
            navigationItem.rightBarButtonItem = sort
        } else if navigationItem.rightBarButtonItem == nil {
            let item = UIBarButtonItem(
                image: UIImage(systemName: "flag.pattern.checkered"),
                style: .plain,
                target: self,
                action: #selector(confirmFinish)
            )
            item.accessibilityLabel = "Завершить голосование"
            navigationItem.rightBarButtonItem = item
        }
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isHandingOff

        if let results {
            for (index, result) in viewModel.orderedOptions(in: results).enumerated() {
                guard let button = buttons[result.id] else {
                    continue
                }
                if screen.optionStack.arrangedSubviews[index] !== button {
                    screen.optionStack.removeArrangedSubview(button)
                    screen.optionStack.insertArrangedSubview(button, at: index)
                }
                button.showResult(
                    result,
                    trailing: viewModel.showsPercentages
                        ? .percentage(result.voteShare)
                        : .voteCount(result.option.voteCount)
                )
            }
        } else {
            for option in poll.options {
                buttons[option.id]?.showChoice(
                    selected: option.id == viewModel.selectedOptionID
                )
            }
        }
    }

}
