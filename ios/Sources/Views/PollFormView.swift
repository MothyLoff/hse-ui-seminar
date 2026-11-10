import SwiftUI

struct PollFormView: View {
    @Environment(Model.self) private var model
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var options = [
        PollOption(title: "", votes: 0),
        PollOption(title: "", votes: 0)
    ]

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var optionTitles: [String] {
        options.map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private var canCreate: Bool {
        !trimmedTitle.isEmpty && optionTitles.count >= 2 && optionTitles.allSatisfy { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Опрос") {
                    TextField("Название", text: $title, axis: .vertical)
                        .lineLimit(1...3)
                    TextField("Описание (необязательно)", text: $description, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section {
                    ForEach($options) { $option in
                        TextField("Вариант ответа", text: $option.title, axis: .vertical)
                            .lineLimit(1...3)
                            .deleteDisabled(options.count <= 2)
                    }
                    .onDelete { offsets in
                        options.remove(atOffsets: offsets)
                    }

                    Button("Добавить вариант", systemImage: "plus") {
                        options.append(PollOption(title: "", votes: 0))
                    }
                } header: {
                    Text("Варианты ответа")
                } footer: {
                    Text("Минимум два варианта. Лишние можно удалить свайпом влево.")
                }
            }
            .navigationTitle("Новый опрос")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать", action: createPoll)
                        .disabled(!canCreate)
                }
            }
        }
    }

    private func createPoll() {
        guard canCreate else { return }

        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        model.add(
            poll: Poll(
                title: trimmedTitle,
                description: trimmedDescription.isEmpty ? nil : trimmedDescription,
                options: optionTitles.map { PollOption(title: $0, votes: 0) }
            )
        )
        dismiss()
    }
}

#Preview {
    @Previewable @State var model = Model()

    PollFormView()
        .environment(model)
}
