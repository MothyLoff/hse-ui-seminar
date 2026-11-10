package ru.hse.uiseminar.polls

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import ru.hse.uiseminar.R
import ru.hse.uiseminar.ui.designsystem.WidgetAppearance

/** Holds only application Context; immutable strings/colors are resolved into WidgetState. */
internal class WidgetStateFactory @Inject constructor(@ApplicationContext private val context: Context) {
    private val appearance get() = WidgetAppearance.from(context)
    private fun text(id: Int) = context.getString(id)
    private fun votes(count: Int) = context.resources.getQuantityString(R.plurals.vote_count, count, count)

    fun card(poll: Poll) = PollCardState(
        question = poll.question,
        summary = context.getString(R.string.poll_summary, votes(poll.totalVotes)),
        status = text(if (poll.ownChoice == null) R.string.poll_open else R.string.poll_voted),
        actionLabel = text(if (poll.ownChoice == null) R.string.open_poll else R.string.view_results),
        appearance = appearance,
    )

    fun field(draft: DraftState, field: DraftField): TextFieldState {
        val invalid = draft.showErrors
        val error = when {
            invalid && draft.value(field).isBlank() -> text(R.string.required_field)
            invalid && field == DraftField.SECOND && draft.first.trim().equals(draft.second.trim(), ignoreCase = true) -> text(R.string.distinct_answers)
            else -> null
        }
        return TextFieldState(
            label = text(when (field) {
                DraftField.QUESTION -> R.string.question_label
                DraftField.FIRST -> R.string.first_answer_label
                DraftField.SECOND -> R.string.second_answer_label
            }),
            value = draft.value(field),
            hint = text(when (field) {
                DraftField.QUESTION -> R.string.question_hint
                DraftField.FIRST -> R.string.first_answer_hint
                DraftField.SECOND -> R.string.second_answer_hint
            }),
            error = error,
            maxLength = if (field == DraftField.QUESTION) PollRepository.QUESTION_LIMIT else PollRepository.ANSWER_LIMIT,
            appearance = appearance,
        )
    }

    fun action() = ActionButtonState(text(R.string.new_poll), true, appearance)
    fun submit(draft: DraftState) = ActionButtonState(text(R.string.create_poll), draft.createdId == null, appearance)

    fun option(poll: Poll, choice: PollChoice): PollOptionState {
        val count = if (choice == PollChoice.FIRST) poll.firstVotes else poll.secondVotes
        val percentage = if (poll.totalVotes == 0) 0 else (count.toLong() * 100 / poll.totalVotes).toInt()
        val selected = poll.ownChoice == choice
        val result = context.getString(R.string.option_result, votes(count), percentage)
        return PollOptionState(
            label = if (choice == PollChoice.FIRST) poll.firstAnswer else poll.secondAnswer,
            resultLabel = if (selected) context.getString(R.string.own_vote_result, result) else result,
            percentage = percentage,
            selected = selected,
            enabled = poll.ownChoice == null,
            appearance = appearance,
        )
    }
}
