package ru.hse.uiseminar.ui.designsystem

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.view.ViewCompat

class PollCardView internal constructor(context: Context) : LinearLayout(context) {
    internal val status = AppCompatTextView(context)
    internal val question = AppCompatTextView(context)
    internal val summary = AppCompatTextView(context)
    internal val action = createActionButton(context)

    init {
        orientation = VERTICAL
        addView(status)
        addView(question)
        addView(summary)
        addView(action, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        ViewCompat.setAccessibilityHeading(question, true)
    }
}

fun createPollCard(context: Context): PollCardView = PollCardView(context)

fun renderPollCard(
    view: PollCardView,
    question: String,
    summary: String,
    status: String,
    actionLabel: String,
    appearance: WidgetAppearance,
    onOpen: () -> Unit,
) = with(view) {
    background = surface(appearance.surface, appearance.border, appearance)
    setPadding(dp(appearance.paddingDp), dp(appearance.paddingDp), dp(appearance.paddingDp), dp(appearance.paddingDp))
    this.status.apply {
        text = status
        body(appearance, appearance.captionSp, bold = true)
        setTextColor(appearance.primary)
    }
    this.question.apply {
        text = question
        body(appearance, appearance.titleSp, bold = true)
        setPadding(0, dp(appearance.gapDp), 0, dp(appearance.gapDp))
    }
    this.summary.apply {
        text = summary
        body(appearance, appearance.captionSp)
        setTextColor(appearance.secondaryText)
        setPadding(0, 0, 0, dp(appearance.gapDp))
    }
    renderActionButton(action, actionLabel, true, appearance, onOpen)
}
