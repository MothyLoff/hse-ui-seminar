import SwiftUI

struct PollOptionView: View {
    let pollOption: PollOption
    let isSelected: Bool
    let onSelect: () -> Void

    private var percentage: Int {
        Int((pollOption.voteFraction * 100).rounded())
    }

    private var fillFraction: Double {
        pollOption.fillPercent() ?? 0
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary, lineWidth: 2)
                    if isSelected {
                        Circle()
                            .fill(.tint)
                            .padding(6)
                    }
                }
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(percentage)%")
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                        Text(pollOption.title)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(pollOption.votes, format: .number)
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }

                    GeometryReader { geometry in
                        Capsule()
                            .fill(.quaternary)
                            .overlay(alignment: .leading) {
                                Capsule()
                                    .fill(.tint.opacity(isSelected ? 1 : 0.6))
                                    .frame(width: max(6, geometry.size.width * fillFraction))
                            }
                    }
                    .frame(height: 6)
                }
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 10)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(pollOption.title)
        .accessibilityValue("\(percentage) процентов, голосов: \(pollOption.votes)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Опция") {
    @Previewable @State var poll = Poll(
        title: "Нормировка",
        options: [
            PollOption(title: "Делать нормировку", votes: 18),
            PollOption(title: "Оставить как есть", votes: 12)
        ]
    )

    PollOptionView(
        pollOption: poll.options[0],
        isSelected: poll.selectedOption === poll.options[0],
        onSelect: { poll.vote(for: poll.options[0]) }
    )
    .padding(20)
    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 24))
    .padding()
}
