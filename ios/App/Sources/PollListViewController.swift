import PollarCore
import UIKit


final class PollListViewController: UIViewController {
    
    private lazy var pollView: CompactPollView = {
        let p = CompactPollView(frame: .zero)
        
        #if DEBUG
        p.configure(with: Poll.debug)
        #endif
        
        p.translatesAutoresizingMaskIntoConstraints = false
        
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Polls"
        view.backgroundColor = .systemBackground
        
        view.addSubview(pollView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            pollView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: 16
            ),
            pollView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: 8
            ),
            pollView.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -8
            )
        ])
    }
    
}
