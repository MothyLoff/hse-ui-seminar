import PollarCore


extension Poll {
    
    var topOptionCount: Int {
        self.options.count(where: \.isTopOption)
    }
    
}
