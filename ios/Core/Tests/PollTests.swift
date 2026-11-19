import Testing
@testable import PollarCore


@Suite("Poll")
struct PollTests {
    
    @Test func pollSetup() {
        let poll = Poll("Куда пойдем обедать?")
        #expect(poll.options.isEmpty)
        poll.addOption("дринкит")
        poll.addOption("кефас")
        poll.addOption("фло")
        #expect(poll.options.count == 3)
        #expect(poll.options.contains(where: { $0.title == "дринкит" }))
        #expect(poll.options.contains(where: { $0.title == "кефас" }))
        #expect(poll.options.contains(where: { $0.title == "фло" }))
    }
    
    @Test func optionAddRemove() {
        let poll = Poll("Куда пойдем обедать?")
        let option1 = poll.addOption("дринкит")
        #expect(!poll.options.isEmpty)
        option1.remove()
        #expect(poll.options.isEmpty)
    }
    
}
