package ru.hse.uiseminar.ui.designsystem

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.RippleDrawable
import android.graphics.drawable.StateListDrawable
import android.view.View
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat

/** Immutable resolved tokens. Each WidgetState carries its own appearance snapshot. */
data class WidgetAppearance(
    @ColorInt val background: Int,
    @ColorInt val surface: Int,
    @ColorInt val text: Int,
    @ColorInt val secondaryText: Int,
    @ColorInt val primary: Int,
    @ColorInt val onPrimary: Int,
    @ColorInt val selectedSurface: Int,
    @ColorInt val border: Int,
    @ColorInt val error: Int,
    val gapDp: Int = 12,
    val paddingDp: Int = 20,
    val radiusDp: Int = 16,
    val touchTargetDp: Int = 52,
    val bodySp: Float = 16f,
    val captionSp: Float = 13f,
    val titleSp: Float = 22f,
) {
    companion object {
        fun from(context: Context) = WidgetAppearance(
            background = ContextCompat.getColor(context, R.color.ds_background),
            surface = ContextCompat.getColor(context, R.color.ds_surface),
            text = ContextCompat.getColor(context, R.color.ds_text),
            secondaryText = ContextCompat.getColor(context, R.color.ds_secondary_text),
            primary = ContextCompat.getColor(context, R.color.ds_primary),
            onPrimary = ContextCompat.getColor(context, R.color.ds_on_primary),
            selectedSurface = ContextCompat.getColor(context, R.color.ds_selected_surface),
            border = ContextCompat.getColor(context, R.color.ds_border),
            error = ContextCompat.getColor(context, R.color.ds_error),
        )
    }
}

internal fun View.dp(value: Int): Int = (value * resources.displayMetrics.density + 0.5f).toInt()

internal fun View.surface(color: Int, stroke: Int, appearance: WidgetAppearance) =
    GradientDrawable().apply {
        setColor(color)
        cornerRadius = dp(appearance.radiusDp).toFloat()
        setStroke(dp(1), stroke)
    }

internal fun View.interactiveBackground(color: Int, border: Int, a: WidgetAppearance): RippleDrawable {
    val states = StateListDrawable().apply {
        addState(intArrayOf(android.R.attr.state_focused), surface(color, a.primary, a))
        addState(intArrayOf(), surface(color, border, a))
    }
    return RippleDrawable(ColorStateList.valueOf(a.primary and 0x00ffffff or 0x24000000), states, null)
}

internal fun TextView.body(a: WidgetAppearance, size: Float = a.bodySp, bold: Boolean = false) {
    textSize = size
    setTextColor(a.text)
    typeface = Typeface.create("sans-serif", if (bold) Typeface.BOLD else Typeface.NORMAL)
    setLineSpacing(0f, 1.15f)
}
