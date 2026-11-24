extension Poll {
    
    public enum VotingError: Error {
        case pollFinished
        case unknownOption
    }
    
}
