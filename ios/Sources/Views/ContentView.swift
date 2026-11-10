import SwiftUI

struct ContentView: View {
    @Environment(Model.self) private var model
    @State private var isShowingPollForm = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.polls) { poll in
                    NavigationLink {
                        ScrollView {
                            PollView(poll: poll)
                                .padding()
                        }
                        .navigationTitle("Опрос")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(poll.title)
                                .font(.headline)

                            if let description = poll.description, !description.isEmpty {
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            Text("Всего голосов: \(poll.voteCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(Color.clear)
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
                        systemImage: "chart.bar.xaxis",
                        description: Text("Нажмите «+», чтобы создать опрос.")
                    )
                }
            }
            .navigationTitle("Опросы")
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
