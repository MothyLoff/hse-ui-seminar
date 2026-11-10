package ru.hse.uiseminar.ui.widget

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ViewModelStore
import androidx.lifecycle.ViewModelStoreOwner
import javax.inject.Provider
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class WidgetLifecycleTest {
    private val dispatcher = StandardTestDispatcher()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `same id survives owner recreation and different widgets have independent state`() {
        val store = ViewModelStore()
        val firstOwner = StoreOwner(store)
        val recreatedOwner = StoreOwner(store)
        val viewModels = WidgetViewModels()
        var creations = 0
        val provider = Provider { TestViewModel().also { creations++ } }
        val first = viewModels.get(firstOwner, "first", TestViewModel::class.java, provider)
        val second = viewModels.get(firstOwner, "second", TestViewModel::class.java, provider)

        first.increment()
        val retained = viewModels.get(recreatedOwner, "first", TestViewModel::class.java, provider)

        assertSame(first, retained)
        assertNotSame(first, second)
        assertEquals(1, retained.state.value.value)
        assertEquals(0, second.state.value.value)
        assertEquals(2, creations)
        assertFalse(first.cleared)

        store.clear()
        assertTrue(first.cleared)
        assertTrue(second.cleared)
    }

    @Test
    fun `rendering pauses while stopped resumes latest state and stops on destroy`() = runTest(dispatcher) {
        val owner = TestLifecycleOwner()
        val viewModel = TestViewModel()
        val rendered = mutableListOf<Int>()
        val subscription = collectWidgetState(viewModel.state, owner) { rendered += it.value }
        runCurrent()
        assertTrue(rendered.isEmpty())

        owner.registry.currentState = Lifecycle.State.STARTED
        runCurrent()
        assertEquals(listOf(0), rendered)
        viewModel.increment()
        runCurrent()
        assertEquals(listOf(0, 1), rendered)

        owner.registry.currentState = Lifecycle.State.CREATED
        runCurrent()
        viewModel.increment()
        viewModel.increment()
        runCurrent()
        assertEquals(listOf(0, 1), rendered)

        owner.registry.currentState = Lifecycle.State.STARTED
        runCurrent()
        assertEquals(listOf(0, 1, 3), rendered)

        owner.registry.currentState = Lifecycle.State.DESTROYED
        runCurrent()
        viewModel.increment()
        runCurrent()
        assertEquals(listOf(0, 1, 3), rendered)
        assertTrue(subscription.isCancelled)
    }

    @Test
    fun `recycling cancels subscription without clearing screen owned viewmodel`() = runTest(dispatcher) {
        val owner = TestLifecycleOwner()
        owner.registry.currentState = Lifecycle.State.STARTED
        val viewModel = TestViewModel()
        val rendered = mutableListOf<Int>()
        val subscription = collectWidgetState(viewModel.state, owner) { rendered += it.value }
        runCurrent()

        subscription.cancel()
        runCurrent()
        viewModel.increment()
        runCurrent()
        assertEquals(listOf(0), rendered)
        assertEquals(1, viewModel.state.value.value)
        assertFalse(viewModel.cleared)
        owner.registry.currentState = Lifecycle.State.DESTROYED
        runCurrent()
    }

    private data class TestState(val value: Int = 0) : WidgetState

    private class TestViewModel : WidgetViewModel<TestState>(TestState()) {
        var cleared = false
            private set

        fun increment() = updateState { it.copy(value = it.value + 1) }

        override fun onCleared() {
            cleared = true
        }
    }

    private class StoreOwner(override val viewModelStore: ViewModelStore) : ViewModelStoreOwner

    private class TestLifecycleOwner : LifecycleOwner {
        val registry = LifecycleRegistry.createUnsafe(this).apply {
            currentState = Lifecycle.State.CREATED
        }
        override val lifecycle: Lifecycle = registry
    }
}
