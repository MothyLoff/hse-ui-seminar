import PollarCore
import UIKit


final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        #if DEBUG
            let polls = Poll.samples
        #else
            let polls: [Poll] = []
        #endif
        let list = PollListViewController(
            viewModel: PollListViewModel(polls: polls)
        )
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(
            rootViewController: list
        )
        self.window = window
        window.makeKeyAndVisible()
    }

}
