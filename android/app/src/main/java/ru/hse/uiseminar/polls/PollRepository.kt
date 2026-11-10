package ru.hse.uiseminar.polls

import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

enum class PollChoice { FIRST, SECOND }

data class Poll(
    val id: Long,
    val question: String,
    val firstAnswer: String,
    val secondAnswer: String,
    val firstVotes: Int = 0,
    val secondVotes: Int = 0,
    val ownChoice: PollChoice? = null,
) {
    val totalVotes: Int get() = firstVotes + secondVotes
}

/** Seminar storage: process memory only, one local vote per poll per app session. */
@Singleton
class PollRepository @Inject constructor() {
    private val mutablePolls = MutableStateFlow<List<Poll>>(emptyList())
    val polls = mutablePolls.asStateFlow()
    private var nextId = 1L

    @Synchronized
    fun create(question: String, first: String, second: String): Long {
        require(question.isNotBlank() && first.isNotBlank() && second.isNotBlank())
        require(!first.trim().equals(second.trim(), ignoreCase = true))
        require(question.length <= QUESTION_LIMIT && first.length <= ANSWER_LIMIT && second.length <= ANSWER_LIMIT)
        val poll = Poll(nextId++, question.trim(), first.trim(), second.trim())
        mutablePolls.value = mutablePolls.value + poll
        return poll.id
    }

    @Synchronized
    fun vote(id: Long, choice: PollChoice): Boolean {
        val poll = mutablePolls.value.firstOrNull { it.id == id } ?: return false
        if (poll.ownChoice != null) return false
        val updated = poll.copy(
            firstVotes = poll.firstVotes + if (choice == PollChoice.FIRST) 1 else 0,
            secondVotes = poll.secondVotes + if (choice == PollChoice.SECOND) 1 else 0,
            ownChoice = choice,
        )
        mutablePolls.value = mutablePolls.value.map { if (it.id == id) updated else it }
        return true
    }

    companion object {
        const val QUESTION_LIMIT = 160
        const val ANSWER_LIMIT = 80
    }
}
