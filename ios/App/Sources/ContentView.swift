import PollarCore
import SwiftUI

struct ContentView: View {
    
    @Namespace private var sheetTransition
    @Namespace private var pollTransition
    
    @State var polls: [Poll] = Poll.debugArray
    
    @State var sheetIsPresented: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(polls.enumerated(), id: \.element.id) { poll in
                        NavigationLink(value: poll.element.id) {
                            PollView(poll: poll.element)
                                .zIndex(-Double(poll.offset))
                                .matchedTransitionSource(
                                    id: poll.element.id,
                                    in: pollTransition
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("Опросы")
            .navigationDestination(for: Poll.ID.self) { id in
                FullscreenPollView(poll: polls.first(where: { $0.id == id })!)
                    .navigationTitle(polls.first(where: { $0.id == id })!.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTransition(.zoom(sourceID: id, in: pollTransition))
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button {
                    sheetIsPresented = true
                } label: {
                    Label("Создать опрос", systemImage: "plus")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 64)
                .buttonStyle(.glass)
                .matchedTransitionSource(id: "createPoll", in: sheetTransition)
                .padding(.horizontal, 32)
                .padding(.top, 16)
            }
            .sheet(isPresented: $sheetIsPresented) {
                Text("Новый опрос")
                    .presentationDetents([.medium])
                    .navigationTransition(.zoom(sourceID: "createPoll", in: sheetTransition))
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        
                    } label: {
                        Image(systemName: "tray")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
