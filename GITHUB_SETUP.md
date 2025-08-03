# Настройка GitHub для ADHD Mind Companion

## 1. Создание репозитория на GitHub

1. Зайдите на https://github.com/new
2. Название: `adhd-mind-companion`
3. Описание: `AI-powered iOS app for ADHD task and note management`
4. Выберите Private или Public
5. НЕ добавляйте README, .gitignore или License (у нас уже есть)
6. Нажмите "Create repository"

## 2. Подключение к GitHub

После создания репозитория выполните:

```bash
cd "/Users/nikita/Desktop/Apps/ADHD Mind Companion/ADHD Mind Companion"

# Добавьте remote (замените YOUR_USERNAME на ваш GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/adhd-mind-companion.git

# Или если используете SSH
git remote add origin git@github.com:YOUR_USERNAME/adhd-mind-companion.git

# Пуш в GitHub
git push -u origin main
```

## 3. Настройка Vercel с GitHub

### Автоматический деплой из GitHub:

1. Зайдите на https://vercel.com/dashboard
2. Нажмите "Import Project"
3. Выберите "Import Git Repository"
4. Выберите ваш репозиторий `adhd-mind-companion`
5. Настройки:
   - Root Directory: `vercel-api`
   - Framework Preset: Other
   - Build Command: оставьте пустым
   - Output Directory: оставьте пустым

### Добавление переменных окружения:

1. В настройках проекта на Vercel
2. Settings → Environment Variables
3. Добавьте:
   - Name: `OPENAI_API_KEY`
   - Value: `ваш-новый-ключ`
   - Environment: Production, Preview, Development

## 4. GitHub Actions (опционально)

Создайте `.github/workflows/ios.yml` для автоматической сборки:

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode.app
      
    - name: Build
      run: |
        xcodebuild build \
          -project "ADHD Mind Companion.xcodeproj" \
          -scheme "ADHD Mind Companion" \
          -destination "platform=iOS Simulator,name=iPhone 15" \
          CODE_SIGNING_ALLOWED=NO
```

## 5. Защита веток

Рекомендуется настроить защиту main ветки:

1. Settings → Branches
2. Add rule
3. Branch name pattern: `main`
4. Включите:
   - Require pull request reviews
   - Dismiss stale pull request approvals
   - Require status checks

## 6. Секреты GitHub

Для CI/CD добавьте секреты:

1. Settings → Secrets and variables → Actions
2. New repository secret
3. Добавьте:
   - `OPENAI_API_KEY`
   - `VERCEL_TOKEN` (получите на vercel.com/account/tokens)

## 7. README Badges

Добавьте в README.md:

```markdown
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
```

## Команды для работы

### Обновление кода
```bash
git add .
git commit -m "Your message"
git push
```

### Создание новой ветки
```bash
git checkout -b feature/new-feature
git push -u origin feature/new-feature
```

### Синхронизация с GitHub
```bash
git pull origin main
```

## Структура в репозитории

```
adhd-mind-companion/
├── ADHD Mind Companion.xcodeproj/
├── ADHD Mind Companion/
│   ├── Models/
│   ├── Views/
│   ├── ViewModels/
│   ├── Services/
│   └── ...
├── vercel-api/
│   ├── api/
│   └── package.json
├── README.md
├── .gitignore
└── LICENSE
```

## После настройки

✅ Код на GitHub
✅ API автоматически деплоится на Vercel
✅ Секреты защищены
✅ CI/CD настроен

Теперь каждый push в main будет автоматически деплоить API на Vercel!