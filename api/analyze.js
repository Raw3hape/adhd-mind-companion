import OpenAI from 'openai';

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { text } = req.body;

    if (!text) {
      return res.status(400).json({ error: 'Text is required' });
    }

    const systemPrompt = `You are an AI assistant for ADHD Mind Companion app. Analyze the user's input and determine:
1. Type: Is this a TASK (actionable item) or NOTE (idea/thought)?
2. If TASK: Extract title, priority (high/medium/low), due date if mentioned, and any notes
3. If NOTE: Extract title, category (Work/Personal/Ideas/Thoughts/Worries), and content
4. If BOTH needed: Create both task and note with linkage

Respond in JSON format:
{
  "type": "task" | "note" | "both",
  "task": {
    "title": "string",
    "priority": "high" | "medium" | "low",
    "dueDate": "ISO date or null",
    "notes": "string",
    "group": "string"
  },
  "note": {
    "title": "string",
    "content": "string",
    "category": "Work" | "Personal" | "Ideas" | "Thoughts" | "Worries"
  },
  "linkedTasks": ["task_id"] // if both
}`;

    const completion = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: text }
      ],
      temperature: 0.7,
      max_tokens: 500,
      response_format: { type: "json_object" }
    });

    const result = JSON.parse(completion.choices[0].message.content);
    
    return res.status(200).json({
      success: true,
      data: result,
      usage: completion.usage
    });

  } catch (error) {
    console.error('OpenAI API error:', error);
    return res.status(500).json({ 
      error: 'Failed to analyze text',
      details: error.message 
    });
  }
}