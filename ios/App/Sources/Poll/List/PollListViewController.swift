import PollarCore
import UIKit


final class PollListViewController: UIViewController, UICollectionViewDelegate {

    private let viewModel: PollListViewModel
    private lazy var screen = PollListView { [weak self] in self?.swipeActions(at: $0) }
    private var dataSource: UICollectionViewDiffableDataSource<Int, Poll.ID>!
    private let filterButton = UIBarButtonItem()
    private lazy var createButton = UIBarButtonItem(
        systemItem: .add,
        primaryAction: UIAction { [weak self] _ in
            self?.openDraft()
        }
    )

    init(viewModel: PollListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() { view = screen }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Голосования"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.rightBarButtonItem = filterButton
        createButton.accessibilityLabel = "Создать голосование"
        toolbarItems = [.flexibleSpace(), createButton]
        screen.collection.delegate = self
        let registration = UICollectionView.CellRegistration<PollListCell, Poll> {
            cell,
            _,
            item in
            cell.configure(with: item)
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: screen.collection) {
            [weak self] collection, path, id in
            guard let item = self?.viewModel.poll(withID: id) else {
                return nil
            }
            return collection.dequeueConfiguredReusableCell(
                using: registration,
                for: path,
                item: item
            )
        }
        refresh(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setToolbarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }

    private func refresh(
        animated: Bool = true,
        changed: Poll.ID? = nil
    ) {
        let dot = UIImage(
            systemName: "circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: DesignComponent.Poll.Badge.activeDotSize.height
            )
        )
        let flag = UIImage(systemName: "flag.pattern.checkered")
        let choices: [(String, Poll.Status?, UIImage?)] = [
            (
                "Активные", .active,
                dot?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
            ),
            (
                "Завершённые", .finished,
                flag?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
            ),
            ("Все", nil, nil),
        ]
        let filters = choices.map { title, value, image in
            UIAction(title: title, image: image, state: viewModel.status == value ? .on : .off)
            { [weak self] _ in
                self?.viewModel.status = value
                self?.refresh()
            }
        }
        let archive = UIAction(
            title: "Показывать архивированные",
            image: UIImage(systemName: "archivebox"),
            state: viewModel.showsArchived ? .on : .off
        ) { [weak self] _ in
            self?.viewModel.showsArchived.toggle()
            self?.refresh()
        }
        filterButton.menu = UIMenu(children: [
            UIMenu(options: .displayInline, children: filters), archive,
        ])
        filterButton.image = UIImage(
            systemName: viewModel.status == nil && !viewModel.showsArchived
                ? "line.3.horizontal.decrease" : "line.3.horizontal.decrease.circle.fill"
        )
        filterButton.accessibilityLabel = "Фильтр голосований"
        let visible = viewModel.visiblePolls
        var snapshot = NSDiffableDataSourceSnapshot<Int, Poll.ID>()
        snapshot.appendSections([0])
        snapshot.appendItems(visible.map(\.id))
        if let changed, snapshot.indexOfItem(changed) != nil,
            dataSource.snapshot().indexOfItem(changed) != nil
        {
            snapshot.reconfigureItems([changed])
        }
        dataSource.apply(snapshot, animatingDifferences: animated)
        if visible.isEmpty {
            var empty = UIContentUnavailableConfiguration.empty()
            empty.text = "Нет голосований"
            empty.secondaryText = "Попробуйте изменить фильтр или создать голосование."
            contentUnavailableConfiguration = empty
        } else {
            contentUnavailableConfiguration = nil
        }
    }

    private func swipeActions(at path: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = dataSource?.itemIdentifier(for: path),
            let item = viewModel.poll(withID: id)
        else {
            return nil
        }
        let action = UIContextualAction(
            style: .normal,
            title: item.isArchived ? "Из архива" : "В архив"
        ) { [weak self] _, _, done in
            guard let self else {
                done(false)
                return
            }
            viewModel.toggleArchive(for: item)
            done(true)
            refresh(changed: id)
        }
        action.image = UIImage(
            systemName: item.isArchived ? "arrow.uturn.backward" : "archivebox"
        )
        action.backgroundColor = item.isArchived ? .systemGray : .systemRed
        return UISwipeActionsConfiguration(actions: [action])
    }

    private func card(for id: Poll.ID) -> CompactPollView? {
        guard let path = dataSource.indexPath(for: id) else {
            return nil
        }
        return (screen.collection.cellForItem(at: path) as? PollListCell)?.card
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt path: IndexPath
    ) {
        collectionView.deselectItem(at: path, animated: false)
        guard let id = dataSource.itemIdentifier(for: path),
            let item = viewModel.poll(withID: id)
        else {
            return
        }
        let detail = FullscreenPollViewController(
            viewModel: FullscreenPollViewModel(poll: item)
        )
        detail.navigationItem.largeTitleDisplayMode = .never
        guard let navigationController else {
            return
        }
        detail.preferredTransition = .zoom { [weak self] _ in self?.card(for: id) }
        detail.onPollChange = { [weak self] in
            self?.refresh(animated: false, changed: id)
        }
        navigationController.pushViewController(detail, animated: true)
    }

    private func openDraft() {
        let draft = PollDraftViewController()
        let sheet = UINavigationController(rootViewController: draft)
        sheet.modalPresentationStyle = .pageSheet
        if let presentation = sheet.sheetPresentationController {
            presentation.detents = [.medium(), .large()]
            presentation.selectedDetentIdentifier = .medium
            presentation.prefersGrabberVisible = true
        }
        var zoomButton = createButton
        sheet.preferredTransition = .zoom(sourceBarButtonItemProvider: { _ in zoomButton })
        draft.onCreate = { [weak self, weak sheet, weak draft] poll in
            guard let self, let sheet else {
                return
            }
            draft?.onCreate = nil
            if viewModel.status != .finished {
                let collection = screen.collection
                collection.setContentOffset(
                    CGPoint(
                        x: collection.contentOffset.x,
                        y: -collection.adjustedContentInset.top
                    ),
                    animated: false
                )
            } else {
                zoomButton = filterButton
            }
            viewModel.insert(poll)
            refresh()
            sheet.dismiss(animated: true)
        }
        present(sheet, animated: true)
    }

}
