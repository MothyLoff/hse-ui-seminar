extension Poll {
    
    public enum CreationError: Error {
        case emptyTitle
        case tooFewOptions
        case emptyOptionTitle
    }
    
}
