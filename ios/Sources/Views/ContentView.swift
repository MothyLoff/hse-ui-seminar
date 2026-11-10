import SwiftUI

struct ContentView: View {
    
    @Environment(Model.self) private var model
    
    var body: some View {
        ForEach(model.polls) { poll in
            Text(poll.title)
        }
    }
}

#Preview {
    ContentView()
        .environment(Model.dbg())
}
