#if DEBUG


import PollarCore


extension Poll {
    
    public static var debug: Poll {
        return Poll(
            "Что круче?",
            description: "Выбираем супер крутой язык программирования для того чтоб написать бизнес логику"
        ) {
            PollOption("Swift", voteCount: 5)
            PollOption("C++", voteCount: 1)
            PollOption("Kotlin", voteCount: 3)
            PollOption("Python", voteCount: 5)
        }
    }
    
}


#endif
