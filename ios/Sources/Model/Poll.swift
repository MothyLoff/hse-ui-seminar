//  Voew.swift, created by Timowa on 10.11.2026

import Foundation


struct Poll: Identifiable {
    
    let id: UUID = UUID()
    
    var title: String
    var description: String?
    
    var options: [PollOption] = []
    
}
