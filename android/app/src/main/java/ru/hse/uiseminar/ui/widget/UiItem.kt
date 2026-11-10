package ru.hse.uiseminar.ui.widget

import android.view.View
import android.view.ViewGroup
import androidx.annotation.MainThread
import androidx.lifecycle.LifecycleOwner
import kotlinx.coroutines.Job

/**
 * A feature's Dagger factory supplies the ViewModel and maps state to designsystem arguments.
 * UiItems are recreated with the screen View; only their ViewModels survive configuration changes.
 */
class UiItem<S : WidgetState, V : View> internal constructor(
    private val viewModel: WidgetViewModel<S>,
    private val create: (parent: ViewGroup) -> V,
    private val render: (view: V, state: S) -> Unit,
) {
    /** Returns an initialized, unattached View. The host decides where to attach it. */
    @MainThread
    fun createView(parent: ViewGroup): V = create(parent).also { view ->
        check(view.parent == null) { "The designsystem factory must return an unattached View" }
        render(view, viewModel.state.value)
    }

    /**
     * Bind once per View. Cancel the returned job before rebinding/recycling the View.
     * For a Fragment, pass viewLifecycleOwner, not the Fragment's own lifecycle.
     */
    @MainThread
    fun bind(view: V, owner: LifecycleOwner): Job =
        collectWidgetState(viewModel.state, owner) { state -> render(view, state) }
}
