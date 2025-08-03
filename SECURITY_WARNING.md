# ⚠️ SECURITY WARNING

## API Key Exposed

The OpenAI API key you shared has been exposed publicly. You must:

1. **IMMEDIATELY revoke this key** at https://platform.openai.com/api-keys
2. **Create a new API key** 
3. **Never share API keys publicly**

## Secure API Key Storage

### Option 1: Environment Variables (Recommended)
Store the key in a `.xcconfig` file that's NOT committed to git:

1. Add your key to `Config.xcconfig`
2. Never commit this file
3. Add it to `.gitignore`

### Option 2: Keychain Storage
For production apps, use iOS Keychain:

```swift
import Security

class KeychainHelper {
    static func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
```

### Option 3: Build Configuration
Add to your app's build settings:
1. Go to Build Settings
2. Add User-Defined Setting
3. Name it `OPENAI_API_KEY`
4. Set different values for Debug/Release

## Best Practices

✅ DO:
- Store keys in environment variables
- Use `.gitignore` for sensitive files
- Rotate keys regularly
- Use different keys for dev/production

❌ DON'T:
- Hardcode keys in source code
- Commit keys to version control
- Share keys in messages/emails
- Use the same key everywhere

## Your Next Steps

1. **Revoke the exposed key NOW**
2. Create a new key
3. Add the new key to `Config.xcconfig`
4. Update `AIService.swift` to read from config
5. Test the app with the new key