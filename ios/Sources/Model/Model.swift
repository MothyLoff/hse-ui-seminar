//  Model.swift, created by Timowa on 10.11.2026

import Observation


@Observable
final class Model {
    
    var polls: [Poll]
    
    init(polls: [Poll] = []) {
        self.polls = polls
    }
    
    func add(poll: Poll) {
        polls.append(poll)
    }
    
}


#if DEBUG

extension Model {
    
    static func dbg() -> Model {
        Model(
            polls: [
                Poll(
                    title: "Латте на АКОСовом",
                    description: "Делать ли нормировку по акосу?",
                    options: [
                        PollOption(title: "Делать кншн", votes: 58),
                        PollOption(title: "Нет, я позер", votes: 0)
                    ]
                ),
                Poll(
                    title: "Сколько получили за акос",
                    options: [
                        PollOption(title: "10", votes: 0),
                        PollOption(title: "9", votes: 0),
                        PollOption(title: "8", votes: 0),
                        PollOption(title: "7", votes: 0),
                        PollOption(title: "6", votes: 0),
                        PollOption(title: "5", votes: 0),
                        PollOption(title: "4", votes: 0),
                        PollOption(title: "3", votes: 0),
                        PollOption(title: "2", votes: 0),
                        PollOption(title: "1", votes: 0),
                        PollOption(title: "0", votes: 0),
                    ]
                ),
                
            ]
        )
    }
    
}

#endif
