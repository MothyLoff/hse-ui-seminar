package ru.hse.uiseminar.ui.designsystem

import android.content.Context
import androidx.appcompat.widget.AppCompatButton

fun createActionButton(context: Context): AppCompatButton = AppCompatButton(context).apply {
    isAllCaps = false
    isSaveEnabled = false
}

fun renderActionButton(
    view: AppCompatButton,
    label: String,
    enabled: Boolean,
    appearance: WidgetAppearance,
    onClick: () -> Unit,
) = with(view) {
    text = label
    body(appearance, bold = true)
    setTextColor(if (enabled) appearance.onPrimary else appearance.secondaryText)
    minHeight = dp(appearance.touchTargetDp)
    setPadding(dp(appearance.paddingDp), dp(appearance.gapDp), dp(appearance.paddingDp), dp(appearance.gapDp))
    backgroundTintList = null
    background = interactiveBackground(
        if (enabled) appearance.primary else appearance.selectedSurface,
        if (enabled) appearance.primary else appearance.border,
        appearance,
    )
    isEnabled = enabled
    setOnClickListener { if (isEnabled) onClick() }
}
