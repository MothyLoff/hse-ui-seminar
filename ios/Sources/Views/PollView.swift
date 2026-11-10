import SwiftUI

struct PollView: View {
    let poll: Poll
    var onOpen: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let onOpen {
                Button(action: onOpen) {
                    header
                }
                .buttonStyle(.plain)
            } else {
                header
            }

            VStack(spacing: 6) {
                ForEach(poll.options) { option in
                    PollOptionView(
                        pollOption: option,
                        isSelected: poll.selectedOption === option,
                        onSelect: { poll.vote(for: option) }
                    )
                }
            }

            Divider()

            Text("Всего голосов: \(poll.voteCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(.primary)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(poll.title)
                .font(.title3.weight(.semibold))

            if let description = poll.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview("Опрос с голосами") {
    @Previewable @State var poll = Poll(
        title: "Нормировка по АКОС",
        description: "Как поступим с результатами контрольной?",
        options: [
            PollOption(title: "Сделать нормировку", votes: 18),
            PollOption(title: "Оставить как есть", votes: 9),
            PollOption(title: "Обсудить на семинаре", votes: 0),
            PollOption(title: "Пока не определился", votes: 3)
        ]
    )

    PollView(poll: poll)
        .padding()
}

#Preview("Без голосов") {
    @Previewable @State var poll = Poll(
        title: "Когда встречаемся?",
        options: [
            PollOption(title: "После лекции", votes: 0),
            PollOption(title: "Вечером после последнего семинара", votes: 0),
            PollOption(title: "На выходных", votes: 0)
        ]
    )

    PollView(poll: poll)
        .padding()
}
