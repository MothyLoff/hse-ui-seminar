package ru.hse.uiseminar.ui.designsystem

import android.content.Context
import android.content.res.ColorStateList
import android.view.View
import android.widget.LinearLayout
import android.widget.ProgressBar
import androidx.appcompat.widget.AppCompatRadioButton
import androidx.appcompat.widget.AppCompatTextView

class PollOptionView internal constructor(context: Context) : LinearLayout(context) {
    val choice = AppCompatRadioButton(context)
    internal val result = AppCompatTextView(context)
    internal val progress = ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal)

    init {
        orientation = VERTICAL
        choice.isSaveEnabled = false
        addView(choice, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        addView(result)
        addView(progress, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        progress.importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
    }
}

fun createPollOption(context: Context): PollOptionView = PollOptionView(context)

fun renderPollOption(
    view: PollOptionView,
    label: String,
    resultLabel: String,
    percentage: Int,
    selected: Boolean,
    enabled: Boolean,
    appearance: WidgetAppearance,
    onVote: () -> Unit,
) = with(view) {
    background = surface(if (selected) appearance.selectedSurface else appearance.surface, if (selected) appearance.primary else appearance.border, appearance)
    setPadding(dp(appearance.paddingDp), dp(appearance.gapDp), dp(appearance.paddingDp), dp(appearance.paddingDp))
    choice.apply {
        text = label
        body(appearance, bold = selected)
        minHeight = dp(appearance.touchTargetDp)
        buttonTintList = ColorStateList.valueOf(appearance.primary)
        isEnabled = enabled
        isChecked = selected
        // render never invokes this listener; the ViewModel owns checked state.
        setOnClickListener { if (isEnabled) onVote() }
    }
    result.apply {
        text = resultLabel
        body(appearance, appearance.captionSp)
        setTextColor(appearance.secondaryText)
        setPadding(0, 0, 0, dp(appearance.gapDp))
    }
    progress.apply {
        max = 100
        this.progress = percentage.coerceIn(0, 100)
        progressTintList = ColorStateList.valueOf(appearance.primary)
        progressBackgroundTintList = ColorStateList.valueOf(appearance.border)
    }
}
