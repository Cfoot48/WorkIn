# OpenAI Moderation Setup (Simple & Free!)

Since Perspective API wasn't accessible, we're using **OpenAI's Moderation API** instead - which is better because:
- ✅ **Free** (included with your OpenAI key)
- ✅ **No extra setup** needed
- ✅ **Works immediately**
- ✅ **Very accurate** - same tech as ChatGPT

## Your API Key

You already have: `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`

## Setup Steps (5 minutes)

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Navigate to Your Project

```bash
cd "/Users/caidfoot/Cursor Projects/WorkIn"
```

### 3. Login to Firebase

```bash
firebase login
```

### 4. Set Your OpenAI API Key

```bash
firebase functions:config:set openai.key="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"
```

### 5. Install Dependencies

```bash
cd functions
npm install
cd ..
```

### 6. Deploy Everything

```bash
# Deploy functions
firebase deploy --only functions

# Deploy firestore rules
firebase deploy --only firestore:rules
```

That's it! 🎉

## How It Works

When a user sends a chat message:

```
1. iOS app calls Cloud Function "moderateMessage"
2. Cloud Function sends message to OpenAI Moderation API
3. OpenAI checks for:
   - Hate speech
   - Harassment
   - Self-harm content
   - Sexual content
   - Violence
4. If flagged → Message blocked
5. If clean → Message sent to chat
```

## What Gets Blocked

OpenAI's moderation checks for:
- **Hate**: Hate speech or content promoting hatred
- **Harassment**: Harassing, bullying, or threatening content
- **Self-harm**: Content promoting self-harm or suicide
- **Sexual**: Sexual content (blocks minors content strictly)
- **Violence**: Violent or gory content

## Testing

After deployment:

1. **Try a clean message**: "Hey everyone, how's your workout going?" ✅ Should work
2. **Try harassment**: "You're stupid" ❌ Should be blocked
3. **Try profanity**: "This workout is fucking hard" ❌ Should be blocked

## View Logs

```bash
# See moderation decisions
firebase functions:log

# Filter to just moderation
firebase functions:log --only moderateMessage
```

Or in Firebase Console:
- Go to **Functions** → **Logs**
- You'll see each moderation decision

## Cost

**FREE** for moderation! OpenAI's moderation endpoint doesn't count against your quota.

## Troubleshooting

### "Missing API Key" Error

```bash
# Check config
firebase functions:config:get

# Should show: openai.key: "sk-or-v1-..."
```

### Function Times Out

The function has a 10-second timeout. If it fails:

```bash
# Check logs
firebase functions:log --only moderateMessage
```

### Message Still Goes Through

- Make sure you deployed firestore rules: `firebase deploy --only firestore:rules`
- Check that `moderated: true` is in the message data

## Before You Deploy

Make sure you:
1. ✅ Added **FirebaseFunctions** package in Xcode (see ADD_FIREBASE_FUNCTIONS.md)
2. ✅ Installed Node.js 18+
3. ✅ Have Firebase Blaze (pay-as-you-go) plan enabled

## Upgrade to Blaze Plan

1. Go to: https://console.firebase.google.com/project/workin-app-a8a42/usage
2. Click **Modify plan**
3. Select **Blaze**
4. Add payment info

**Don't worry about costs:**
- First 2M function calls/month: FREE
- After that: $0.40 per 1M calls
- Your chat app will likely stay in free tier

## Alternative: Skip Cloud Functions

If you don't want to set up Cloud Functions, the app has a fallback filter built-in that will work client-side. It's simpler but less sophisticated.

To use fallback only:
- Don't deploy the functions
- The Swift code will use the local fallback when Cloud Function fails
- Chat works immediately but with basic filtering
