#if DEBUG
import PollarCore


extension Poll {

    static var samples: [Poll] {
        let lunch = try! Poll(
            title: "Где обедаем после семинара?",
            description: "Выберем место, куда пойдём всей группой.",
            optionTitles: [
                "В столовой", "В кафе у кампуса", "В пекарне", "Возьмём с собой",
                "В бистро", "В парке", "В пиццерии", "В лапшичной",
                "В бургерной", "В кофейне", "В чайной", "В фудкорте",
                "В хинкальной", "В блинной",
            ]
        )
        let languages = try! Poll(
            title: "Какой язык разбираем следующим?",
            optionTitles: ["Swift", "Kotlin"]
        )
        for (option, count) in zip(languages.options, [16, 10]) {
            for _ in 0..<count {
                try! languages.vote(for: option.id)
            }
        }
        languages.finish()
        return [lunch, languages]
    }

}
#endif
