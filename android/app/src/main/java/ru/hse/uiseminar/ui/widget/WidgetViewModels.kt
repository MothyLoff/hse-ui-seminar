package ru.hse.uiseminar.ui.widget

import androidx.annotation.MainThread
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelStoreOwner
import javax.inject.Inject
import javax.inject.Provider

/** Dagger creates dependencies; the screen's ViewModelStore owns widget ViewModel instances. */
class WidgetViewModels @Inject constructor() {
    @MainThread
    fun <VM : WidgetViewModel<*>> get(
        owner: ViewModelStoreOwner,
        widgetId: String,
        modelClass: Class<VM>,
        provider: Provider<VM>,
    ): VM {
        require(widgetId.isNotBlank()) { "widgetId must be stable and non-blank" }
        val factory = object : ViewModelProvider.Factory {
            override fun <T : ViewModel> create(modelClass: Class<T>): T =
                modelClass.cast(provider.get())!!
        }
        return ViewModelProvider(owner, factory)["${modelClass.name}:$widgetId", modelClass]
    }
}
