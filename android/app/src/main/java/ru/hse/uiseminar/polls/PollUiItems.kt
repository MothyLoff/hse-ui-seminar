package ru.hse.uiseminar.polls

import androidx.appcompat.widget.AppCompatButton
import androidx.lifecycle.ViewModelStoreOwner
import javax.inject.Inject
import javax.inject.Provider
import ru.hse.uiseminar.ui.designsystem.PollCardView
import ru.hse.uiseminar.ui.designsystem.PollOptionView
import ru.hse.uiseminar.ui.designsystem.TextFieldView
import ru.hse.uiseminar.ui.designsystem.createActionButton
import ru.hse.uiseminar.ui.designsystem.createPollCard
import ru.hse.uiseminar.ui.designsystem.createPollOption
import ru.hse.uiseminar.ui.designsystem.createTextField
import ru.hse.uiseminar.ui.designsystem.renderActionButton
import ru.hse.uiseminar.ui.designsystem.renderPollCard
import ru.hse.uiseminar.ui.designsystem.renderPollOption
import ru.hse.uiseminar.ui.designsystem.renderTextField
import ru.hse.uiseminar.ui.widget.UiItem
import ru.hse.uiseminar.ui.widget.WidgetViewModels

/** The screen's only construction API; no ViewModel or WidgetState constructors at call sites. */
internal class PollUiItems @Inject constructor(
    private val viewModels: WidgetViewModels,
    private val cards: PollCardViewModel.Factory,
    private val fields: TextFieldViewModel.Factory,
    private val options: PollOptionViewModel.Factory,
    private val submitButtons: SubmitButtonViewModel.Factory,
    private val actions: Provider<ActionButtonViewModel>,
    private val drafts: Provider<DraftViewModel>,
) {
    fun card(owner: ViewModelStoreOwner, pollId: Long, onOpen: () -> Unit): UiItem<PollCardState, PollCardView> {
        val vm = viewModels.get(owner, "poll:$pollId", PollCardViewModel::class.java, Provider { cards.create(pollId) })
        vm.refreshAppearance()
        return UiItem(vm, { createPollCard(it.context) }) { view, state ->
            renderPollCard(view, state.question, state.summary, state.status, state.actionLabel, state.appearance, onOpen)
        }
    }

    fun newPoll(owner: ViewModelStoreOwner, onClick: () -> Unit): UiItem<ActionButtonState, AppCompatButton> {
        val vm = viewModels.get(owner, "new-poll", ActionButtonViewModel::class.java, actions)
        vm.refreshAppearance()
        return UiItem(vm, { createActionButton(it.context) }) { view, state ->
            renderActionButton(view, state.label, state.enabled, state.appearance, onClick)
        }
    }

    fun form(owner: ViewModelStoreOwner, onCreated: (Long) -> Unit, onInvalid: (DraftField) -> Unit): FormItems {
        val draft = viewModels.get(owner, "draft", DraftViewModel::class.java, drafts)
        val textFields = DraftField.entries.associateWith { field ->
            val vm = viewModels.get(owner, "field:${field.name}", TextFieldViewModel::class.java, Provider { fields.create(draft, field) })
            vm.refreshAppearance()
            UiItem(vm, { createTextField(it.context) }) { view, state ->
                renderTextField(view, state.label, state.value, state.hint, state.error, state.maxLength, state.appearance, vm::edit)
            }
        }
        val submit = viewModels.get(owner, "submit", SubmitButtonViewModel::class.java, Provider { submitButtons.create(draft) })
        submit.refreshAppearance()
        val action = UiItem(submit, { createActionButton(it.context) }) { view, state ->
            renderActionButton(view, state.label, state.enabled, state.appearance) {
                val id = draft.submit()
                if (id != null) onCreated(id) else draft.state.value.firstInvalidField()?.let(onInvalid)
            }
        }
        return FormItems(textFields, action)
    }

    fun option(owner: ViewModelStoreOwner, pollId: Long, choice: PollChoice): UiItem<PollOptionState, PollOptionView> {
        val vm = viewModels.get(owner, "poll:$pollId:${choice.name}", PollOptionViewModel::class.java, Provider { options.create(pollId, choice) })
        vm.refreshAppearance()
        return UiItem(vm, { createPollOption(it.context) }) { view, state ->
            renderPollOption(view, state.label, state.resultLabel, state.percentage, state.selected, state.enabled, state.appearance, vm::vote)
        }
    }
}

internal data class FormItems(
    val fields: Map<DraftField, UiItem<TextFieldState, TextFieldView>>,
    val submit: UiItem<ActionButtonState, AppCompatButton>,
)
