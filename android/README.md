# HSE UI Seminar · Android

Минимальный запускаемый Android-проект на Android Views. Реализация голосований, экраны, модели данных
и граф навигации намеренно не добавлены.

Архитектура виджетов и DI: [ARCHITECTURE.md](ARCHITECTURE.md).
Контракт для разработчика UI: [ui.designsystem/README.md](ui.designsystem/README.md).

## Запуск

Открыть именно эту папку (`android`), а не корень репозитория, в Android Studio
Rabbit 2 (2026.2.2) или новее: более ранняя Rabbit 1 не поддерживает AGP 9.5.
Дождаться успешного Gradle Sync и окончания индексации.

В `.run/` хранятся общие конфигурации, доступные в верхней панели IDE:

- `app` — сборка и запуск приложения на выбранном устройстве/эмуляторе.
- `Android Lint` — проверка `:app:lintDebug`, без запуска приложения. Отчёт:
  `app/build/reports/lint-results-debug.html`.

Подсветка Kotlin и инспекции редактора работают после успешной синхронизации;
наличие run configuration само по себе не исправляет ошибки Gradle Sync.

- Gradle daemon использует JDK 25 (`gradle/gradle-daemon-jvm.properties`);
  целевой bytecode приложения — Java 17.
- Android SDK Platform 37, Build Tools 36.0.0 (версия по умолчанию AGP).
- Устройство/эмулятор Android 8.0+ (API 26).
- Путь к SDK задаётся через `local.properties` (`sdk.dir=...`) или `ANDROID_HOME`.
  `local.properties` не хранится в Git.

```sh
./gradlew :app:assembleDebug :app:lintDebug :app:testDebugUnitTest
./gradlew :app:assembleRelease
```

Release включает R8 и resource shrinking; подпись для публикации не настроена.
Подключены unit/UI-тестовые зависимости; базовые unit-тесты архитектуры находятся в `app/src/test`.

## Зависимости

Последние стабильные опубликованные версии проверены 10.11.2026; все версии
зафиксированы в `gradle/libs.versions.toml`, без динамических `+` и preview-релизов.

| Компонент | Версия |
| --- | --- |
| Gradle Wrapper | 9.9.0 |
| Android Gradle Plugin | 9.5.1 |
| Kotlin / Serialization plugin | 2.4.21 |
| KSP | 2.3.13 |
| Dagger / Hilt | 2.60.1 |
| Core KTX / AppCompat / Activity | 1.19.1 / 1.8.0 / 1.13.0 |
| Lifecycle / Navigation Fragments | 2.11.0 / 2.10.2 |
| kotlinx.coroutines / kotlinx.serialization | 1.11.0 / 1.12.0 |

AGP 9 использует встроенную поддержку Kotlin; `org.jetbrains.kotlin.android` и kapt
не нужны. Версия встроенного Kotlin явно выровнена с compiler plugins через
`buildscript`. Hilt подключён через KSP, есть `@HiltAndroidApp` Application и
`@AndroidEntryPoint` Activity. Dagger API доступен напрямую.

Подключены Navigation Fragment/UI, View Binding и Lifecycle для ViewModel и
`repeatOnLifecycle`. Compose и его compiler plugin удалены.
Библиотеки сети и БД не добавлены: для семинара достаточно состояния в памяти.

## Сборка

Включены configuration cache (включая parallel store/load), build cache, daemon,
parallel execution, isolated projects, parallel tooling и file-system watching.
Jetifier выключен; включены incremental Kotlin/KSP, non-transitive R classes.
Логика сборки не использует `allprojects`/`subprojects`, чтобы сохранять изоляцию.
Wrapper проверяет SHA-256 скачиваемого дистрибутива.

У KSP 2.3.13 есть [известная регрессия при одновременной обработке нескольких
модулей](https://github.com/google/ksp/issues/3286). KSP сейчас используется только в `app`;
перед добавлением других модулей с KSP нужно обновиться до релиза с исправлением.

Источники версий: [Gradle](https://gradle.org/releases/),
[AGP](https://developer.android.com/build/releases/agp-9-5-0-release-notes),
[Kotlin](https://kotlinlang.org/docs/releases.html),
[AndroidX](https://developer.android.com/jetpack/androidx/versions),
[Dagger/Hilt](https://dagger.dev/hilt/gradle-setup),
[KSP](https://github.com/google/ksp/releases), официальные Google Maven и Maven Central.

## Проверка setup

Локально успешно выполнены debug- и release-сборки (release с R8), Android Lint
(`No issues found`), повторная сборка с `Configuration cache entry reused` и
чистая сборка с восстановлением задач `FROM-CACHE` для исходного setup.
После перехода на Views прошли debug/release-сборки, lint обоих модулей и
3 unit-теста жизненного цикла виджетов.
Запуск на устройстве/эмуляторе не выполнялся.
