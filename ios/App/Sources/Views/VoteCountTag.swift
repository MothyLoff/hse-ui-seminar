import PollarCore
import SwiftUI


struct VoteCountTag: View {
    
    @ScaledMetric private var bodyFontSize = DesignComponent.DefaultFontSize.body
    @ScaledMetric private var tagFontSize = DesignComponent.DefaultFontSize.tag
    
    let poll: Poll
    
    private var text: String {
        return poll.totalVoteCount > .zero
        ? String(poll.totalVoteCount)
        : "No votes yet"
    }
    
    var body: some View {
        HStack(spacing: DesignComponent.Poll.Tag.spacing) {
            Image(systemName: "person.fill")
                .font(.system(size: tagFontSize))
            Text(text)
                .font(.system(size: bodyFontSize))
        }
        .fontWeight(.semibold)
        .foregroundStyle(Color(uiColor: .systemBackground))
        .padding(.horizontal, DesignComponent.Poll.Tag.Padding.Inner.horizontal)
        .padding(.vertical, DesignComponent.Poll.Tag.Padding.Inner.vertical)
        .background {
            ZStack {
                if self.poll.topOptionCount == self.poll.options.count {
                    Capsule()
                        .stroke(
                            .background.secondary,
                            lineWidth: DesignComponent.Poll.Tag.strokeWidth
                        )
                }
                Capsule()
                    .foregroundStyle(.primary)
            }
        }
    }
}
