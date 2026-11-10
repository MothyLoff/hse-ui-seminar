# ui.designsystem

Самостоятельный Android Views модуль. Compose, Dagger, ViewModel и StateFlow здесь
не используются. Бизнес-данные приходят аргументами; события возвращаются callbacks.

## Компоненты

| Виджет | Создание / обновление | Назначение |
| --- | --- | --- |
| ActionButton | createActionButton / renderActionButton | Кнопка создания/перехода, enabled и оформление |
| TextField | createTextField / renderTextField | Подпись, текст, placeholder, ошибка, ограничение длины |
| PollCard | createPollCard / renderPollCard | Вопрос, число голосов, статус и действие открытия |
| PollOption | createPollOption / renderPollOption | RadioButton, число голосов, процент и полоса результата |

Исходники: `src/main/java/ru/hse/uiseminar/ui/designsystem/`.
`WidgetAppearance` — immutable набор цветов и размеров. Палитры лежат в
`values/colors.xml` и `values-night/colors.xml`; описание оформления — `../DESIGN.md`.

## Контракт

- `create*` один раз создаёт View без parent. Экран добавляет её в layout.
- `render*` обновляет существующую View из аргументов. Не создаёт ViewModel.
- `TextField` не отправляет пользовательский callback при программном render
  и не сбрасывает текст/курсор, если значение не изменилось.
- Listener устанавливается один раз или заменяется; обработчики не накапливаются.
- Все данные, влияющие на оформление, передаются явно через аргументы и appearance.
- Используются стандартные доступные Android controls, подписи полей, заголовки,
  видимый focus/ripple и минимальная высота интерактивных элементов 52 dp.
- Context и View нельзя сохранять в singleton или ViewModel.

Готовые адаптеры State → аргументы находятся в `app/.../polls/PollUiItems.kt`.
Экран получает эту фабрику через Hilt, а каждая ViewModel принадлежит экрану.
Общая архитектура: [ARCHITECTURE.md](../ARCHITECTURE.md).
