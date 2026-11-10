import SwiftUI

@main
struct VotingApp: App {
    
    @State private var model = Model.dbg()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }
    }
}
