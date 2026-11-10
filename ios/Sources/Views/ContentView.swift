import SwiftUI

struct ContentView: View {
    @Environment(Model.self) private var model
    @State private var isShowingPollForm = false
    @State private var path: [Poll.ID] = []
    @Namespace private var pollTransition

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(model.polls) { poll in
                    PollView(poll: poll, onOpen: {
                        path.append(poll.id)
                    })
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 24))
                    .matchedTransitionSource(id: poll.id, in: pollTransition)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .swipeActions {
                        Button("Удалить", systemImage: "trash", role: .destructive) {
                            model.remove(poll: poll)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .overlay {
                if model.polls.isEmpty {
                    ContentUnavailableView(
                        "Опросов пока нет",
                        systemImage: "chart.bar.xaxis"
                    )
                }
            }
            .navigationTitle("Опросы")
            .navigationDestination(for: Poll.ID.self) { pollID in
                if let poll = model.polls.first(where: { $0.id == pollID }) {
                    ScrollView {
                        PollView(poll: poll)
                    }
                    .background(.background.secondary)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .navigationTransition(.zoom(sourceID: poll.id, in: pollTransition))
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Создать опрос", systemImage: "plus") {
                        isShowingPollForm = true
                    }
                }
            }
            .sheet(isPresented: $isShowingPollForm) {
                PollFormView()
            }
        }
    }
}

#Preview {
    @Previewable @State var model = Model.dbg()

    ContentView()
        .environment(model)
}

#Preview("Пустой список") {
    @Previewable @State var model = Model()

    ContentView()
        .environment(model)
}
