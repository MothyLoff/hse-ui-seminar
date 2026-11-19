import PollarCore
import SwiftUI


struct PollOptionView: View {
    
    @ScaledMetric private var bodyFontSize = DesignComponent.DefaultFontSize.body
    
    var option: Poll.Option
    
    var body: some View {
        HStack(
            alignment: .center,
            spacing: DesignComponent.Poll.Option.Bullet.spacing
        ) {
            Circle()
                .frame(
                    width: DesignComponent.Poll.Option.Bullet.size.width,
                    height: DesignComponent.Poll.Option.Bullet.size.height
                )
                .padding(.leading, DesignComponent.Poll.Option.Padding.leading)
                .padding(.vertical, DesignComponent.Poll.Option.Padding.vertical)
            
            HStack(alignment: .firstTextBaseline, spacing: .zero) {
                Text(option.title)
                Spacer()
                Text(String(option.votePercentage) + "%")
            }
            .font(.system(size: bodyFontSize))
            .padding(.trailing, DesignComponent.Poll.Option.Padding.trailing)
            .fontWeight(.semibold)
        }
        .foregroundStyle(
            option.isTopOption
            ? Color(uiColor: .systemBackground)
            : .secondary
        )
        .background {
            Capsule()
                .foregroundStyle(
                    option.isTopOption
                    ? .primary
                    : Color(uiColor: .tertiarySystemBackground)
                )
        }
    }
    
}

#Preview {
    
    @Previewable @State var polls: [Poll] = [Poll.debugInstance]
    
    VStack(spacing: 16) {
        ForEach(
            polls.enumerated(), id: \.element.id
        ) { poll in
            PollView(poll: poll.element)
                .padding(.horizontal, 8)
                .zIndex(-Double(poll.offset))
        }
    }
        
}
