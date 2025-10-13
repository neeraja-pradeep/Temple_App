# Firebase Configuration Setup

## 🔐 Setting Up Firebase API Keys

### For Development:

1. Copy the template file:

   ```bash
   cp lib/core/config/firebase_config.dart.template lib/core/config/firebase_config.dart
   ```

2. Edit `lib/core/config/firebase_config.dart` and replace `YOUR_FIREBASE_WEB_API_KEY_HERE` with your actual Firebase Web API Key.

### For Production:

1. Use environment variables instead of hardcoded values
2. Set up secure storage for API keys
3. Never commit API keys to version control

## 🔑 Getting Your Firebase Web API Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `temple-project-2d223`
3. Go to Project Settings (gear icon)
4. Go to General tab
5. Scroll down to "Your apps" section
6. Find your web app or create one
7. Copy the "Web API Key" value

## 🚨 Security Notes

- The `firebase_config.dart` file is in `.gitignore` and will NOT be committed to Git
- Always use the template file for new setups
- Never share your API keys in public repositories
- Use environment variables for production deployments

## 📁 File Structure

```
lib/core/config/
├── firebase_config.dart          # Your actual config (ignored by Git)
├── firebase_config.dart.template # Template for new setups
└── README.md                     # This file
```












