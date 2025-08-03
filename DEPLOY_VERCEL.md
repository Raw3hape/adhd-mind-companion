# Деплой API на Vercel

## 1. Подготовка

```bash
cd vercel-api
npm install
```

## 2. Установка Vercel CLI (если еще не установлен)

```bash
npm i -g vercel
```

## 3. Логин в Vercel

```bash
vercel login
```

## 4. Добавление секретного ключа OpenAI

```bash
vercel secrets add openai-api-key "sk-proj-..."
```

⚠️ **ВАЖНО**: Используйте НОВЫЙ ключ, не тот что был скомпрометирован!

## 5. Деплой

```bash
vercel --prod
```

При первом деплое Vercel спросит:
- Set up and deploy? → Yes
- Which scope? → Выберите ваш аккаунт
- Link to existing project? → No
- Project name? → adhd-mind-companion (или другое)
- Directory? → ./
- Override settings? → No

## 6. Получение URL

После деплоя вы получите URL вида:
```
https://adhd-mind-companion-xxx.vercel.app
```

## 7. Обновление iOS приложения

Откройте файл `/Services/AIService.swift` и замените URL:

```swift
private let baseURL = "https://ВАШ-URL.vercel.app/api/analyze"
```

## 8. Тестирование API

```bash
curl -X POST https://ВАШ-URL.vercel.app/api/analyze \
  -H "Content-Type: application/json" \
  -d '{"text":"I need to call the doctor tomorrow"}'
```

## Команды для управления

### Просмотр логов
```bash
vercel logs
```

### Переменные окружения
```bash
vercel env ls
```

### Редеплой
```bash
vercel --prod
```

## Структура проекта

```
vercel-api/
├── api/
│   └── analyze.js       # API endpoint
├── package.json         # Dependencies
├── vercel.json         # Vercel config
└── .gitignore          # Git ignore
```

## Безопасность

✅ API ключ хранится на Vercel
✅ iOS приложение не содержит ключей
✅ CORS настроен для мобильных приложений
✅ Используется HTTPS

## Мониторинг

Отслеживайте использование на:
- https://vercel.com/dashboard
- https://platform.openai.com/usage