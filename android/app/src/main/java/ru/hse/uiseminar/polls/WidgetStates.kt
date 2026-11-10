package ru.hse.uiseminar.polls

import ru.hse.uiseminar.ui.designsystem.WidgetAppearance
import ru.hse.uiseminar.ui.widget.WidgetState

internal data class PollCardState(
    val question: String,
    val summary: String,
    val status: String,
    val actionLabel: String,
    val appearance: WidgetAppearance,
) : WidgetState

internal data class TextFieldState(
    val label: String,
    val value: String,
    val hint: String,
    val error: String?,
    val maxLength: Int,
    val appearance: WidgetAppearance,
) : WidgetState

internal data class ActionButtonState(
    val label: String,
    val enabled: Boolean,
    val appearance: WidgetAppearance,
) : WidgetState

internal data class PollOptionState(
    val label: String,
    val resultLabel: String,
    val percentage: Int,
    val selected: Boolean,
    val enabled: Boolean,
    val appearance: WidgetAppearance,
) : WidgetState

internal enum class DraftField { QUESTION, FIRST, SECOND }

internal data class DraftState(
    val question: String = "",
    val first: String = "",
    val second: String = "",
    val showErrors: Boolean = false,
    val createdId: Long? = null,
) : WidgetState {
    fun value(field: DraftField): String = when (field) {
        DraftField.QUESTION -> question
        DraftField.FIRST -> first
        DraftField.SECOND -> second
    }

    fun firstInvalidField(): DraftField? = when {
        question.isBlank() -> DraftField.QUESTION
        first.isBlank() -> DraftField.FIRST
        second.isBlank() || first.trim().equals(second.trim(), ignoreCase = true) -> DraftField.SECOND
        else -> null
    }
}
