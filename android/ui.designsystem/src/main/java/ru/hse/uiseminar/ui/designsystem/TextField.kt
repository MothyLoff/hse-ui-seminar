package ru.hse.uiseminar.ui.designsystem

import android.content.Context
import android.text.Editable
import android.text.InputFilter
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.LinearLayout
import androidx.appcompat.widget.AppCompatEditText
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.view.ViewCompat

class TextFieldView internal constructor(context: Context) : LinearLayout(context) {
    internal val label = AppCompatTextView(context)
    val input = AppCompatEditText(context)
    internal val error = AppCompatTextView(context)
    internal var rendering = false
    internal var onTextChanged: (String) -> Unit = {}

    init {
        orientation = VERTICAL
        input.id = View.generateViewId()
        input.isSaveEnabled = false // WidgetState, not Android's view hierarchy, owns the value.
        input.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES or InputType.TYPE_TEXT_FLAG_MULTI_LINE
        input.imeOptions = EditorInfo.IME_ACTION_NEXT
        input.setHorizontallyScrolling(false)
        label.labelFor = input.id
        label.setOnClickListener { input.requestFocus() }
        addView(label)
        addView(input, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        addView(error, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        error.accessibilityLiveRegion = View.ACCESSIBILITY_LIVE_REGION_POLITE
        input.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                if (!rendering) onTextChanged(s?.toString().orEmpty())
            }
            override fun afterTextChanged(s: Editable?) = Unit
        })
    }
}

fun createTextField(context: Context): TextFieldView = TextFieldView(context)

fun renderTextField(
    view: TextFieldView,
    label: String,
    value: String,
    hint: String,
    error: String?,
    maxLength: Int,
    appearance: WidgetAppearance,
    onTextChanged: (String) -> Unit,
) = with(view) {
    this.onTextChanged = onTextChanged
    this.label.apply {
        text = label
        body(appearance, appearance.captionSp, bold = true)
        setPadding(0, 0, 0, dp(appearance.gapDp / 2))
    }
    input.apply {
        this.hint = hint
        body(appearance)
        setHintTextColor(appearance.secondaryText)
        minHeight = dp(appearance.touchTargetDp)
        setPadding(dp(appearance.paddingDp), dp(appearance.gapDp), dp(appearance.paddingDp), dp(appearance.gapDp))
        filters = arrayOf(InputFilter.LengthFilter(maxLength))
        backgroundTintList = null
        background = interactiveBackground(appearance.surface, if (error == null) appearance.border else appearance.error, appearance)
        // Avoid resetting the cursor/composing span for a value just entered by the user.
        if (text.toString() != value) {
            rendering = true
            try {
                setText(value)
                setSelection(value.length.coerceAtMost(text?.length ?: 0))
            } finally {
                rendering = false
            }
        }
        ViewCompat.setStateDescription(this, error)
    }
    this.error.apply {
        text = error.orEmpty()
        body(appearance, appearance.captionSp)
        setTextColor(appearance.error)
        // Reserve one line so validation does not move the next input.
        minLines = 1
        visibility = if (error == null) View.INVISIBLE else View.VISIBLE
    }
}
