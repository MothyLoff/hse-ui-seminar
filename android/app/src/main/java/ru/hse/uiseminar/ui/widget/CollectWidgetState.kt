package ru.hse.uiseminar.ui.widget

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

internal fun <S : WidgetState> collectWidgetState(
    state: StateFlow<S>,
    owner: LifecycleOwner,
    render: (S) -> Unit,
): Job = owner.lifecycleScope.launch {
    owner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        state.collect { render(it) }
    }
}
