import PollarCore
import SwiftUI


struct PollView: View {
    
    @ScaledMetric private var titleFontSize = DesignComponent.DefaultFontSize.title
    @ScaledMetric private var bodyFontSize = DesignComponent.DefaultFontSize.body
    @ScaledMetric private var tagFontSize = DesignComponent.DefaultFontSize.tag
    
    let poll: Poll
    
    var body: some View {
        VStack(spacing: .zero) {
            pollHeaderView
                .padding(.horizontal, DesignComponent.Poll.Header.Padding.horizontal)
                .padding(.vertical, DesignComponent.Poll.Header.Padding.vertical)
            opptionList
                .padding(.horizontal, DesignComponent.Poll.OptionList.padding)
                .padding(.bottom, DesignComponent.Poll.OptionList.padding)
        }
        .background {
            RoundedRectangle(
                cornerRadius: DesignComponent.Poll.Background.cornerRadius
            )
            .foregroundStyle(.background.secondary)
        }
        .overlay(alignment: .bottomTrailing) {
            VoteCountTag(poll: self.poll)
                .frame(height: .zero)
                .padding(.horizontal, DesignComponent.Poll.Tag.Padding.Outer.horizontal)
                .offset(DesignComponent.Poll.Tag.offset)
        }
    }
    
    private var pollHeaderView: some View {
        VStack(alignment: .leading, spacing: DesignComponent.Poll.Header.spacing) {
            HStack(spacing: .zero) {
                Text(poll.title)
                    .font(.system(size: titleFontSize))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: bodyFontSize))
            }
            .fontWeight(.semibold)
            if let description = poll.description {
                Text(description)
                    .font(.system(size: bodyFontSize))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var opptionList: some View {
        VStack(spacing: DesignComponent.Poll.OptionList.spacing) {
            ForEach(poll.options) { option in
                PollOptionView(option: option)
            }
        }
        .frame(
            height: pollOptionViewSpace(
                forCount: min(poll.topOptionCount + 1, poll.options.count)
            ),
            alignment: .top
        )
        .clipped()
        .overlay(alignment: .bottom) {
            Capsule()
                .frame(
                    height: poll.topOptionCount < poll.options.count
                    ? DesignComponent.Poll.Option.height
                    : .zero
                )
                .foregroundStyle(
                    Gradient(
                        colors: [
                            .clear,
                            Color(uiColor: .secondarySystemBackground)
                        ]
                    )
                )
        }
    }
    
    private func pollOptionViewSpace(
        forCount: Int = 1
    ) -> CGFloat {
        let gaps: CGFloat = DesignComponent.Poll.OptionList.spacing
            * CGFloat(forCount - 1)
        let viewHeights: CGFloat = DesignComponent.Poll.Option.height
            * CGFloat(forCount)
        return viewHeights + gaps
    }
    
}


#Preview {
    
    @Previewable @State var polls: [Poll] = Poll.debugArray
    
    ScrollView {
        VStack(spacing: 16) {
            ForEach(
                polls.enumerated(),
                id: \.element.id
            ) { poll in
                PollView(poll: poll.element)
                    .padding(.horizontal, 8)
                    .zIndex(-Double(poll.offset))
            }
        }
    }
        
}
