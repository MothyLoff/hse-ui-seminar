import PollarCore
import SwiftUI


struct FullscreenPollView: View {
    
    let poll: Poll
    
    var body: some View {
        VStack(alignment: .leading) {
            if let description = poll.description {
                Text(description)
                    .padding(.horizontal, 8)
            }
            
            VStack(spacing: DesignComponent.Poll.OptionList.spacing) {
                ForEach(poll.options) { option in
                    PollOptionView(option: option)
                }
            }
        }
        .padding(.horizontal)
    }
    
}


#Preview {
    FullscreenPollView(poll: Poll.debugInstance)
}
