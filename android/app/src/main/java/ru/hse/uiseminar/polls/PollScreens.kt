package ru.hse.uiseminar.polls

import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import androidx.appcompat.widget.AppCompatTextView
import androidx.appcompat.widget.Toolbar
import androidx.core.content.ContextCompat
import androidx.core.os.bundleOf
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.repeatOnLifecycle
import androidx.navigation.fragment.findNavController
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import ru.hse.uiseminar.R
import ru.hse.uiseminar.ui.designsystem.TextFieldView
import ru.hse.uiseminar.ui.designsystem.WidgetAppearance
import ru.hse.uiseminar.ui.widget.UiItem
import ru.hse.uiseminar.ui.widget.WidgetState

@AndroidEntryPoint
class PollListFragment : Fragment() {
    @Inject internal lateinit var items: PollUiItems
    private val model: PollsScreenViewModel by viewModels()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        ScreenView(requireContext(), getString(R.string.app_name))

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val screen = view as ScreenView
        screen.description(getString(R.string.list_intro))
        screen.mount(items.newPoll(this) {
            if (findNavController().currentDestination?.id == R.id.poll_list) {
                findNavController().navigate(R.id.open_create)
            }
        }, viewLifecycleOwner)
        val cards = LinearLayout(requireContext()).apply { orientation = LinearLayout.VERTICAL }
        screen.content.addView(cards)
        val subscriptions = mutableListOf<Job>()
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                // Counts are rendered by each card's ViewModel. Rebuild only for structural changes.
                model.polls.map { polls -> polls.map(Poll::id) }.distinctUntilChanged().collect { ids ->
                    subscriptions.forEach(Job::cancel)
                    subscriptions.clear()
                    cards.removeAllViews()
                    if (ids.isEmpty()) {
                        cards.addView(screen.text(getString(R.string.empty_title), title = true))
                        cards.addView(screen.text(getString(R.string.empty_description)))
                    }
                    ids.forEach { id ->
                        val item = items.card(this@PollListFragment, id) {
                            if (findNavController().currentDestination?.id == R.id.poll_list) {
                                findNavController().navigate(R.id.open_poll, bundleOf("pollId" to id))
                            }
                        }
                        val card = item.createView(cards)
                        cards.addView(card, screen.itemLayout())
                        subscriptions += item.bind(card, viewLifecycleOwner)
                    }
                }
            }
        }
    }
}

@AndroidEntryPoint
class CreatePollFragment : Fragment() {
    @Inject internal lateinit var items: PollUiItems

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        ScreenView(requireContext(), getString(R.string.new_poll)) { findNavController().popBackStack() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val screen = view as ScreenView
        screen.description(getString(R.string.form_intro))
        val fields = mutableMapOf<DraftField, TextFieldView>()
        val form = items.form(this, onCreated = {
            // The list is the owning screen and observes the new poll from the repository.
            findNavController().popBackStack()
        }, onInvalid = { field ->
            fields[field]?.input?.requestFocus()
        })
        form.fields.forEach { (field, item) -> fields[field] = screen.mount(item, viewLifecycleOwner) }
        screen.mount(form.submit, viewLifecycleOwner)
    }
}

@AndroidEntryPoint
class PollDetailFragment : Fragment() {
    @Inject internal lateinit var items: PollUiItems
    private val model: PollsScreenViewModel by viewModels()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        ScreenView(requireContext(), getString(R.string.vote_title)) { findNavController().popBackStack() }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val screen = view as ScreenView
        val id = requireArguments().getLong("pollId")
        val poll = model.polls.value.firstOrNull { it.id == id }
        if (poll == null) {
            screen.description(getString(R.string.poll_missing))
            return
        }
        screen.content.addView(screen.text(poll.question, title = true))
        val status = screen.description(getString(R.string.choose_one)).apply {
            accessibilityLiveRegion = View.ACCESSIBILITY_LIVE_REGION_POLITE
        }
        PollChoice.entries.forEach { choice -> screen.mount(items.option(this, id, choice), viewLifecycleOwner) }
        viewLifecycleOwner.lifecycleScope.launch {
            viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
                model.polls.map { all -> all.firstOrNull { it.id == id }?.ownChoice }.distinctUntilChanged().collect { choice ->
                    status.setText(if (choice == null) R.string.choose_one else R.string.vote_recorded)
                }
            }
        }
    }
}

/** Screen layout only. Stateful feature controls are always supplied through UiItem. */
private class ScreenView(context: Context, title: String, onBack: (() -> Unit)? = null) : LinearLayout(context) {
    private val appearance = WidgetAppearance.from(context)
    val content = LinearLayout(context).apply {
        orientation = VERTICAL
        setPadding(px(appearance.paddingDp), px(appearance.gapDp), px(appearance.paddingDp), px(appearance.paddingDp))
    }
    init {
        orientation = VERTICAL
        setBackgroundColor(appearance.background)
        val toolbar = Toolbar(context).apply {
            this.title = title
            setTitleTextColor(appearance.text)
            if (onBack != null) {
                navigationIcon = ContextCompat.getDrawable(context, R.drawable.ic_arrow_back)?.mutate()?.apply { setTint(appearance.text) }
                navigationContentDescription = context.getString(R.string.back)
                setNavigationOnClickListener { onBack() }
            }
        }
        addView(toolbar, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        addView(ScrollView(context).apply {
            id = R.id.screen_scroll
            isFillViewport = true
            addView(content)
        }, LayoutParams(LayoutParams.MATCH_PARENT, 0, 1f))
    }
    private fun px(value: Int) = (value * resources.displayMetrics.density + 0.5f).toInt()
    fun itemLayout() = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT).apply { bottomMargin = px(appearance.gapDp) }
    fun text(value: String, title: Boolean = false) = AppCompatTextView(context).apply {
        text = value
        textSize = if (title) appearance.titleSp else appearance.bodySp
        setTextColor(if (title) appearance.text else appearance.secondaryText)
        typeface = Typeface.create("sans-serif", if (title) Typeface.BOLD else Typeface.NORMAL)
        setLineSpacing(0f, 1.15f)
        setPadding(0, 0, 0, px(appearance.paddingDp))
        if (title) ViewCompat.setAccessibilityHeading(this, true)
    }
    fun description(value: String): AppCompatTextView = text(value).also(content::addView)
    fun <S : WidgetState, V : View> mount(item: UiItem<S, V>, owner: LifecycleOwner): V =
        item.createView(content).also { child ->
            content.addView(child, itemLayout())
            item.bind(child, owner)
        }
}
