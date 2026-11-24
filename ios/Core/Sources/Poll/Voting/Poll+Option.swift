import Foundation

extension Poll {
    
    public struct Option: Identifiable {
        public let id = UUID()
        public let title: String
        public internal(set) var voteCount = 0

        init(title: String) {
            self.title = title
        }
    }
    
}
