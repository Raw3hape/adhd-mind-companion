# ADHD Mind Companion API

Vercel serverless API for ADHD Mind Companion iOS app.

## Setup

1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Install dependencies:
```bash
npm install
```

3. Add your OpenAI API key to Vercel:
```bash
vercel secrets add openai-api-key "your-api-key-here"
```

4. Deploy to Vercel:
```bash
vercel --prod
```

## Local Development

1. Create `.env.local` file:
```
OPENAI_API_KEY=your_api_key_here
```

2. Run locally:
```bash
vercel dev
```

## API Endpoints

### POST /api/analyze
Analyzes text input and returns structured task/note data.

Request:
```json
{
  "text": "I need to call the doctor tomorrow about my prescription"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "type": "task",
    "task": {
      "title": "Call doctor",
      "priority": "high",
      "dueDate": "2024-08-04",
      "notes": "About prescription",
      "group": "Health"
    }
  }
}
```

## Deployment URL

After deployment, your API will be available at:
`https://your-project-name.vercel.app/api/analyze`