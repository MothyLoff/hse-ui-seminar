package ru.hse.uiseminar.polls

import org.junit.Assert.*
import org.junit.Test

class PollRepositoryTest {
    @Test
    fun `creation trims input and voting changes only the selected poll once`() {
        val repository = PollRepository()
        val first = repository.create("  Вопрос  ", " Да ", " Нет ")
        val second = repository.create("Другой вопрос", "Первый", "Второй")
        val oldSnapshot = repository.polls.value
        assertTrue(repository.vote(first, PollChoice.SECOND))
        assertFalse(repository.vote(first, PollChoice.FIRST))
        assertFalse(repository.vote(999, PollChoice.FIRST))
        assertEquals(0, oldSnapshot.first().totalVotes)
        assertEquals("Вопрос", repository.polls.value.first().question)
        assertEquals(1, repository.polls.value.first().secondVotes)
        assertEquals(0, repository.polls.value.first { it.id == second }.totalVotes)
    }

    @Test
    fun `invalid drafts create no records and valid submit cannot be repeated`() {
        val repository = PollRepository()
        val draft = DraftViewModel(repository)
        assertNull(draft.submit())
        assertTrue(draft.state.value.showErrors)
        draft.edit(DraftField.QUESTION, "Тема?")
        draft.edit(DraftField.FIRST, " Один ")
        draft.edit(DraftField.SECOND, "один")
        assertNull(draft.submit())
        assertEquals(DraftField.SECOND, draft.state.value.firstInvalidField())
        draft.edit(DraftField.SECOND, "Другой")
        assertNotNull(draft.submit())
        assertNull(draft.submit())
        assertEquals(1, repository.polls.value.size)
    }
}
