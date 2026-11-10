package ru.hse.uiseminar.ui.widget

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

abstract class WidgetViewModel<S : WidgetState>(initialState: S) : ViewModel() {
    private val mutableState = MutableStateFlow(initialState)
    val state: StateFlow<S> = mutableState.asStateFlow()

    /** The reducer must be pure: update may evaluate it more than once under contention. */
    protected fun updateState(reducer: (S) -> S) {
        mutableState.update(reducer)
    }
}
