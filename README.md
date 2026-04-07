# DophamineGuard 🧠

> **Твой цифровой детокс в кармане** — Flutter-приложение для контроля экранного времени, осознанного использования смартфона и борьбы с цифровой зависимостью.

---

## 📱 О проекте

**DophamineGuard** помогает пользователям:
- 📊 Отслеживать экранное время по каждому приложению
- ⏱️ Устанавливать лимиты на использование соцсетей
- 🔥 Поддерживать стрик дней без «срывов»
- 🧠 Проходить квизы по цифровому здоровью
- 🎯 Включать **Фокус-режим** (Premium) — блокировка соцсетей на время сессии
- 🏆 Зарабатывать достижения и бонусные минуты

---

## 🛠️ Технологии

| Стек | Версия |
|------|--------|
| Flutter | ≥ 3.11 |
| Dart | ≥ 3.11 |
| Firebase Auth | ^6.2.0 |
| Cloud Firestore | ^6.2.0 |
| go_router | ^17.1.0 |
| fl_chart | ^1.2.0 |
| google_fonts | ^8.0.2 |
| lucide_icons | ^0.257.0 |

---

## 🚀 Быстрый старт

### Требования

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11
- Dart ≥ 3.11
- Android Studio / VS Code с Flutter-плагином
- [Firebase CLI](https://firebase.google.com/docs/cli) (для настройки Firebase)
- JDK 11 или выше

Проверить установку Flutter:
```bash
flutter doctor
```

### 1. Клонировать репозиторий

```bash
git clone https://github.com/<your-username>/DophamineGuardApp.git
cd DophamineGuardApp
```

### 2. Установить зависимости

```bash
flutter pub get
```

### 3. Настройка Firebase

Приложение использует Firebase для аутентификации и хранения данных.

#### Для Android:
1. Создайте проект в [Firebase Console](https://console.firebase.google.com/)
2. Добавьте Android-приложение с package name `com.example.dophamine_guard`
3. Скачайте `google-services.json` и поместите в `android/app/`

#### Для iOS:
1. В том же проекте Firebase добавьте iOS-приложение
2. Скачайте `GoogleService-Info.plist` и поместите в `ios/Runner/`

#### Включите в Firebase:
- **Authentication** → Email/Password
- **Cloud Firestore** → создайте базу данных (режим test mode для разработки)

> ⚠️ Без Firebase приложение запустится, но аутентификация не будет работать.

### 4. Запуск

#### На Android-устройстве / эмуляторе:
```bash
flutter run
```

#### На iOS-симуляторе (только macOS):
```bash
flutter run -d ios
```

#### Выбрать конкретное устройство:
```bash
flutter devices          # посмотреть список
flutter run -d <device-id>
```

---

## 📁 Структура проекта

```
lib/
├── core/
│   ├── app_state.dart          # Глобальное состояние приложения
│   └── theme/
│       ├── app_colors.dart     # Цветовая палитра
│       ├── app_gradients.dart  # Градиенты
│       └── app_theme.dart      # MaterialTheme конфигурация
├── presentation/
│   ├── screens/
│   │   ├── dashboard_screen.dart      # Главный экран
│   │   ├── profile_screen.dart        # Статистика (графики)
│   │   ├── achievements_screen.dart   # Достижения
│   │   ├── settings_screen.dart       # Настройки
│   │   ├── quiz_screen.dart           # Квиз осознанности
│   │   ├── focus_mode_screen.dart     # Фокус-режим (Premium)
│   │   ├── change_limit_screen.dart   # Управление лимитами
│   │   ├── premium_screen.dart        # Экран подписки
│   │   ├── auth_screen.dart           # Авторизация
│   │   ├── onboarding_screen.dart     # Онбординг
│   │   ├── goal_setup_screen.dart     # Настройка цели
│   │   └── block_overlay_screen.dart  # Экран блокировки
│   └── widgets/
│       ├── main_shell.dart            # Bottom navigation shell
│       └── dashboard_widgets.dart     # Виджеты дашборда
└── routes/
    └── app_router.dart                # GoRouter конфигурация
```

---

## ✨ Функции

### Бесплатная версия
| Функция | Описание |
|---------|----------|
| 📊 Дашборд | Экранное время, стрик, лимиты приложений |
| 📈 Статистика | График по дням и часам (fl_chart) |
| 🏆 Достижения | Разблокируемые бейджи за прогресс |
| 🧠 Квиз | Зарабатывает бонусное время за правильные ответы |
| ⚙️ Лимиты | Настройка лимитов для Instagram, TikTok, YouTube |

### Premium
| Функция | Описание |
|---------|----------|
| 🎯 Фокус-режим | Таймер + блокировка соцсетей на время сессии |
| 🤖 AI Инсайты | Персональный анализ привычек за неделю |
| 📋 История сессий | Полная история фокус-сессий |

---

## 🔧 Сборка для продакшна

### Android APK:
```bash
flutter build apk --release
# Файл: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (для Google Play):
```bash
flutter build appbundle --release
```

### iOS (только macOS):
```bash
flutter build ios --release
```

---

## ⚙️ Troubleshooting

### Ошибка с Java версией при сборке Android
Убедитесь что используется JDK 11 или 17. В `android/app/build.gradle.kts`:
```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}
```

### `GoException: no routes for location`
GoRouter инициализируется один раз при старте. После изменения маршрутов нужен **Hot Restart** (`Shift+R` в терминале), а не Hot Reload.

### Firebase не подключается
Убедитесь что `google-services.json` находится в `android/app/` и `GoogleService-Info.plist` в `ios/Runner/`.

---

## 📄 Лицензия

MIT License — используйте свободно в учебных и личных целях.

---

<div align="center">
  <p>Сделано с ❤️ на Flutter</p>
</div>
