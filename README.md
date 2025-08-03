# ADHD Mind Companion 🧠

AI-powered iOS app that transforms scattered thoughts into organized tasks and notes, designed specifically for ADHD minds.

## 🌟 Features

### Voice Capture
- **Instant thought capture** - Press and speak your mind
- **AI analysis** - Automatically determines if input should be a task or note
- **Smart linking** - Creates connected tasks and notes when needed

### Intelligent Organization
- **My Day** - Focus on today's priorities without overwhelm
- **Tasks** - Full task management with groups and subtasks
- **Notes** - Capture ideas, thoughts, and references
- **Universal Search** - Find anything across all content

### AI-Powered (GPT-4o mini)
- Context-aware categorization
- Priority suggestion
- Due date extraction
- Automatic grouping

## 📱 Screenshots

<div align="center">
  <img src="docs/capture.png" width="250" alt="Capture Screen">
  <img src="docs/myday.png" width="250" alt="My Day Screen">
  <img src="docs/tasks.png" width="250" alt="Tasks Screen">
</div>

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- OpenAI API key
- Node.js (for Vercel deployment)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/adhd-mind-companion.git
cd adhd-mind-companion
```

2. **Deploy API to Vercel**
```bash
cd vercel-api
npm install
vercel login
vercel secrets add openai-api-key "your-api-key"
vercel --prod
```

3. **Update iOS app with your Vercel URL**

Open `Services/AIService.swift` and update:
```swift
private let baseURL = "https://your-deployment.vercel.app/api/analyze"
```

4. **Run the app**
- Open `ADHD Mind Companion.xcodeproj` in Xcode
- Select your development team
- Build and run on a real device (microphone required)

## 🏗 Architecture

### iOS App (SwiftUI + MVVM)
```
ADHD Mind Companion/
├── Models/          # Core Data entities
├── Views/           # SwiftUI views
├── ViewModels/      # Business logic
├── Services/        # API, Speech, Data
└── Utilities/       # Themes, Extensions
```

### Vercel API
```
vercel-api/
├── api/
│   └── analyze.js   # OpenAI integration
├── package.json
└── vercel.json
```

## 🔑 Key Technologies

- **SwiftUI** - Modern declarative UI
- **Core Data** - Local persistence
- **Speech Framework** - Voice recognition
- **OpenAI GPT-4o mini** - AI analysis
- **Vercel** - Serverless API hosting

## 🎨 Design Philosophy

Built specifically for ADHD minds:
- **Minimal friction** - Capture thoughts instantly
- **AI decides** - No manual categorization needed
- **Visual clarity** - Clean, focused interface
- **Smart defaults** - Sensible priorities and grouping

## 🔒 Security

- API keys stored securely on Vercel
- No sensitive data in iOS app
- All communication over HTTPS
- Local data encrypted with Core Data

## 📋 Core Features

### Task Management
- Priority levels (Low, Medium, High, Urgent)
- Due dates with smart parsing
- Subtasks and dependencies
- Group organization

### Note Taking
- Automatic categorization
- Linked tasks creation
- Full-text search
- Important note highlighting

### AI Analysis
- Context understanding
- Action item extraction
- Priority suggestion
- Category assignment

## 🛠 Development

### Requirements
- macOS 14+
- Xcode 15+
- iOS 17+ device
- OpenAI API account

### Setup Development Environment

1. Install dependencies
```bash
cd vercel-api
npm install
```

2. Create `.env.local` for local testing
```
OPENAI_API_KEY=your_api_key
```

3. Run Vercel locally
```bash
vercel dev
```

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 💡 Future Enhancements

- [ ] Widget for quick capture
- [ ] Apple Watch app
- [ ] Siri integration
- [ ] Calendar sync
- [ ] Medication reminders
- [ ] Focus timer with breaks
- [ ] Habit tracking
- [ ] Mood logging

## 📧 Support

For issues or questions, please open an issue on GitHub.

---

Built with ❤️ for the ADHD community