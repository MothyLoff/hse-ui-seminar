import PollarCore


extension Poll {
    
    static var debugInstance: Poll {
        return Poll(
            "Что круче?",
            description: "Выбираем супер крутой язык порграммирования йоу и какой то еще длинный текст короче да"
        ) {
            PollOption("Java", voteCount: 3)
            PollOption("C++", voteCount: 3)
            PollOption("Kotlin", voteCount: 2)
            PollOption("Swift", voteCount: 1)
        }
    }
    
    static var debugArray: [Poll] {
        return [
            Poll.debugInstance,
            
            Poll("Two options") {
                PollOption("a", voteCount: 10)
                PollOption("b", voteCount: 7)
            },
            
            Poll("Tie") {
                PollOption("a", voteCount: 5)
                PollOption("b", voteCount: 5)
            },
            
            Poll("No Votes") {
                PollOption("a")
                PollOption("b")
            },
        ]
    }
    
}
