import UIKit


final class PollListView: UIView {

    let collection: UICollectionView

    init(
        swipeActions:
            @escaping UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider
    ) {
        var layout = UICollectionLayoutListConfiguration(appearance: .plain)
        layout.showsSeparators = false
        layout.backgroundColor = .systemBackground
        layout.trailingSwipeActionsConfigurationProvider = swipeActions
        collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(using: layout)
        )
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        collection.backgroundColor = .systemBackground
        collection.contentInset.bottom = 12
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collection.frame = bounds
        addSubview(collection)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

}
