package ru.hse.uiseminar.polls

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import ru.hse.uiseminar.ui.widget.WidgetViewModel

@HiltViewModel
class PollsScreenViewModel @Inject constructor(repository: PollRepository) : ViewModel() {
    val polls = repository.polls
}

internal class PollCardViewModel @AssistedInject constructor(
    repository: PollRepository,
    private val states: WidgetStateFactory,
    @Assisted val pollId: Long,
) : WidgetViewModel<PollCardState>(states.card(repository.polls.value.first { it.id == pollId })) {
    private var poll = repository.polls.value.first { it.id == pollId }
    init {
        viewModelScope.launch {
            repository.polls.map { all -> all.firstOrNull { it.id == pollId } }
                .filterNotNull().distinctUntilChanged().collect {
                    poll = it
                    refreshAppearance()
                }
        }
    }
    fun refreshAppearance() = updateState { states.card(poll) }

    @AssistedFactory interface Factory { fun create(pollId: Long): PollCardViewModel }
}

internal class DraftViewModel @Inject constructor(private val repository: PollRepository) : WidgetViewModel<DraftState>(DraftState()) {
    fun edit(field: DraftField, value: String) {
        val limit = if (field == DraftField.QUESTION) PollRepository.QUESTION_LIMIT else PollRepository.ANSWER_LIMIT
        updateState { current ->
            if (current.createdId != null) current else when (field) {
                DraftField.QUESTION -> current.copy(question = value.take(limit))
                DraftField.FIRST -> current.copy(first = value.take(limit))
                DraftField.SECOND -> current.copy(second = value.take(limit))
            }
        }
    }

    fun submit(): Long? {
        val draft = state.value
        if (draft.createdId != null) return null // Ignore repeated taps on the same form.
        if (draft.firstInvalidField() != null) {
            updateState { it.copy(showErrors = true) }
            return null
        }
        val id = repository.create(draft.question, draft.first, draft.second)
        updateState { it.copy(createdId = id) }
        return id
    }
}

internal class TextFieldViewModel @AssistedInject constructor(
    private val states: WidgetStateFactory,
    @Assisted private val draft: DraftViewModel,
    @Assisted private val field: DraftField,
) : WidgetViewModel<TextFieldState>(states.field(draft.state.value, field)) {
    init { viewModelScope.launch { draft.state.collect { refreshAppearance() } } }
    fun edit(value: String) = draft.edit(field, value)
    fun refreshAppearance() = updateState { states.field(draft.state.value, field) }
    @AssistedFactory interface Factory { fun create(draft: DraftViewModel, field: DraftField): TextFieldViewModel }
}

internal class ActionButtonViewModel @Inject constructor(private val states: WidgetStateFactory) : WidgetViewModel<ActionButtonState>(states.action()) {
    fun refreshAppearance() = updateState { states.action() }
}

internal class SubmitButtonViewModel @AssistedInject constructor(
    private val states: WidgetStateFactory,
    @Assisted private val draft: DraftViewModel,
) : WidgetViewModel<ActionButtonState>(states.submit(draft.state.value)) {
    init { viewModelScope.launch { draft.state.collect { refreshAppearance() } } }
    fun refreshAppearance() = updateState { states.submit(draft.state.value) }
    @AssistedFactory interface Factory { fun create(draft: DraftViewModel): SubmitButtonViewModel }
}

internal class PollOptionViewModel @AssistedInject constructor(
    private val repository: PollRepository,
    private val states: WidgetStateFactory,
    @Assisted private val pollId: Long,
    @Assisted private val choice: PollChoice,
) : WidgetViewModel<PollOptionState>(states.option(repository.polls.value.first { it.id == pollId }, choice)) {
    private var poll = repository.polls.value.first { it.id == pollId }
    init {
        viewModelScope.launch {
            repository.polls.map { all -> all.firstOrNull { it.id == pollId } }
                .filterNotNull().distinctUntilChanged().collect {
                    poll = it
                    refreshAppearance()
                }
        }
    }
    fun vote() { repository.vote(pollId, choice) }
    fun refreshAppearance() = updateState { states.option(poll, choice) }
    @AssistedFactory interface Factory { fun create(pollId: Long, choice: PollChoice): PollOptionViewModel }
}
