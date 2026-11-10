//  Option.swift, created by Timowa on 10.11.2026

import Foundation


struct PollOption: Identifiable {
    
    var id: UUID = UUID()
    
    var title: String
    var votes: Int
    
}


extension PollOption: Comparable {
    
    static func < (
        lhs: borrowing PollOption,
        rhs: borrowing PollOption
    ) -> Bool {
        lhs.votes < rhs.votes
    }
    
}
