import SwiftUI


extension View {
    
    func bottomButton(
        namespace: Namespace.ID? = nil,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) -> some View {
        self
            .safeAreaInset(edge: .bottom) {
                ZStack {
                    LinearGradient(
                        colors: [.clear, Color(uiColor: .systemBackground).opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    .frame(height: 64)
                    
                    Button {
                        action()
                    } label: {
                        content()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 64)
                    .padding(.horizontal, 34)
                    .buttonStyle(.glass)
                    .matchedTransitionSourceIf(id: "bottomButton", namespace: namespace)
                }
                .padding(.top, 16)
            }
    }
    
}

fileprivate extension View {
    
    @ViewBuilder
    func matchedTransitionSourceIf(
        id: String,
        namespace: Namespace.ID?
    ) -> some View {
        if let namespace {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
    
}


#Preview {
    ScrollView {
        Color.green
            .frame(height: 1000)
    }
    .bottomButton {
        print("pressed")
    } content: {
        Text("Hello")
    }
}
