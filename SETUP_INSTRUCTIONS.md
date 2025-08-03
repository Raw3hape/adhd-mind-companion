# ADHD Mind Companion - Setup Instructions

## 🚀 Quick Setup

### 1. OpenAI API Key Configuration
Open `/Services/AIService.swift` and add your OpenAI API key:
```swift
private let apiKey = "YOUR_OPENAI_API_KEY_HERE"
```

Get your API key from: https://platform.openai.com/api-keys

### 2. Xcode Project Setup

1. Open `ADHD Mind Companion.xcodeproj` in Xcode
2. Select your development team in project settings
3. Choose your iPhone as the run destination (microphone doesn't work in simulator)
4. Press Cmd+R to build and run

### 3. Required Permissions

The app will automatically request these permissions on first launch:
- **Microphone** - For voice capture
- **Speech Recognition** - For converting speech to text

### 4. Core Data Setup

The Core Data model is already configured with:
- **CDTask** - Task management
- **CDNote** - Notes and ideas
- **CDCategory** - Organization categories

## 📱 Features

### Voice Capture
- Tap the microphone button to start recording
- AI automatically determines if input should be a task or note
- Creates linked items when both are needed

### AI Processing
- Uses GPT-4o mini for efficient processing
- Analyzes context to categorize content
- Suggests priorities and due dates for tasks

### Organization
- **My Day** - Today's focus items
- **Tasks** - Full task management with groups
- **Notes** - Ideas and thoughts with categories
- **Search** - Universal search across all content

## 🎨 Customization

### Theme Support
The app supports both light and dark modes automatically.

### Categories
Default categories:
- 💼 Work
- 🏠 Personal
- 💡 Ideas
- 🎯 Projects
- 💭 Thoughts

## 🔧 Troubleshooting

### Microphone Not Working
- Check Settings > Privacy > Microphone
- Ensure app has permission enabled

### API Errors
- Verify your OpenAI API key is correct
- Check you have credits in your OpenAI account
- Ensure internet connection is active

### Build Errors
1. Clean build folder: Cmd+Shift+K
2. Delete derived data
3. Restart Xcode

## 📝 Development Notes

### Architecture
- **MVVM Pattern** - Clean separation of concerns
- **SwiftUI** - Modern declarative UI
- **Core Data** - Local persistence
- **Combine** - Reactive programming

### File Structure
```
ADHD Mind Companion/
├── Models/          # Data models
├── Views/           # UI components
├── ViewModels/      # Business logic
├── Services/        # API and system services
├── Utilities/       # Helpers and extensions
└── Resources/       # Assets and config
```

## 🚦 Running the App

1. Connect your iPhone via USB
2. Trust the computer on your iPhone
3. Select your iPhone as the run destination
4. Press Cmd+R to build and run
5. The app will install and launch on your device

## 💡 Tips

- Use natural language when speaking
- AI works best with clear, concise thoughts
- Tasks are created for actionable items
- Notes are created for ideas and thoughts
- Both can be created from a single input

## 📧 Support

For issues or questions about the app architecture, refer to the inline documentation in each file.