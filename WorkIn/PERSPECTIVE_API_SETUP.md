# Perspective API Content Moderation Setup

This guide shows how to set up Google's Perspective API for professional content moderation in the WorkIn app chat.

## What is Perspective API?

Perspective API uses machine learning to detect toxic comments, profanity, threats, and other harmful content. It's the same technology used by major platforms like The New York Times, Wikipedia, and Reddit.

## Prerequisites

- Firebase Blaze (pay-as-you-go) plan
- Google Cloud account (same as Firebase account)
- Node.js 18+ installed

## Step 1: Enable Perspective API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your Firebase project (**workin-app-a8a42**)
3. **IMPORTANT**: The Perspective API is NOT in the API library. You need to:
   - Go directly to: https://console.cloud.google.com/marketplace/product/google/commentanalyzer.googleapis.com
   - Make sure **workin-app-a8a42** is selected in the project dropdown at the top
   - Click **Enable**
   - OR: Click **APIs & Services** → **Enable APIs and Services** → Search for "Perspective Comment Analyzer API" or "Comment Analyzer API"
4. After enabling, go to **Credentials** → **Create Credentials** → **API Key**
5. Copy the API key (you'll need it in Step 4)

**Alternative - Direct Link:**
Once your project is selected, go to:
https://console.cloud.google.com/apis/library/commentanalyzer.googleapis.com?project=workin-app-a8a42

## Step 2: Upgrade to Firebase Blaze Plan

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your **WorkIn** project
3. Go to **Settings** → **Usage and billing**
4. Click **Modify plan** → **Select Blaze plan**
5. Add payment information

**Cost Estimate:**
- Cloud Functions: Free for first 2M invocations/month
- Perspective API: Free for first 1M requests/month
- **For a chat app, you'll likely stay in free tier**

## Step 3: Install Firebase CLI and Initialize Functions

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Navigate to your project
cd "/Users/caidfoot/Cursor Projects/WorkIn"

# Login to Firebase
firebase login

# Initialize Firebase (select Functions only)
firebase init

# When prompted:
# - Select "Functions"
# - Choose JavaScript
# - Install dependencies: Yes
```

## Step 4: Configure the Perspective API Key

```bash
# Set the API key in Firebase Functions config
firebase functions:config:set perspective.key="YOUR_API_KEY_HERE"

# Replace YOUR_API_KEY_HERE with the key from Step 1
```

## Step 5: Install Dependencies

```bash
cd functions
npm install
cd ..
```

## Step 6: Deploy Cloud Functions

```bash
# Deploy the functions to Firebase
firebase deploy --only functions

# You should see:
# ✔  functions[moderateMessage(us-central1)] Successful create operation
# ✔  functions[autoModerateOnWrite(us-central1)] Successful create operation
```

## Step 7: Update Firestore Security Rules

```bash
# Deploy the security rules
firebase deploy --only firestore:rules

# This updates the rules to require moderated flag on chat messages
```

## Step 8: Test the Integration

1. **Build and run the iOS app**
2. **Try sending a clean message**: "Hello everyone!" - Should work ✅
3. **Try sending toxic content**: "You're an idiot" - Should be blocked ❌
4. **Check Firebase Console**:
   - Go to Functions → Logs
   - You should see moderation decisions logged

## How It Works

### Message Flow:

```
User types message
    ↓
iOS App calls Cloud Function "moderateMessage"
    ↓
Cloud Function sends to Perspective API
    ↓
Perspective API returns toxicity scores
    ↓
If scores are below threshold → Allow message
If scores are above threshold → Block message
    ↓
iOS App receives response
    ↓
If allowed → Save to Firestore
If blocked → Show error to user
```

### Attributes Checked:

- **TOXICITY**: Rude, disrespectful, or unreasonable comment
- **SEVERE_TOXICITY**: Very hateful, aggressive, or disrespectful
- **IDENTITY_ATTACK**: Negative comment about identity/demographic
- **INSULT**: Insulting, inflammatory, or negative comment
- **PROFANITY**: Swear words, curse words, or other obscene language
- **THREAT**: Describes an intention to inflict pain, injury, or violence

### Thresholds (in functions/index.js):

```javascript
TOXICITY: 0.7          // Block if >70% toxic
SEVERE_TOXICITY: 0.5   // Block if >50% severely toxic
IDENTITY_ATTACK: 0.7   // Block if >70% identity attack
INSULT: 0.7            // Block if >70% insulting
PROFANITY: 0.8         // Block if >80% profanity
THREAT: 0.7            // Block if >70% threatening
```

**You can adjust these in `functions/index.js`**

## Monitoring

### View Moderation Logs:

```bash
# View recent function logs
firebase functions:log

# View specific function logs
firebase functions:log --only moderateMessage
```

### Firebase Console:
- Go to **Functions** → **Logs** to see all moderation decisions
- Go to **Firestore** → **moderationLogs** to see blocked messages (if using autoModerateOnWrite)

## Troubleshooting

### "Missing API Key" Error
```bash
# Check if key is set
firebase functions:config:get

# Re-set the key
firebase functions:config:set perspective.key="YOUR_KEY"

# Redeploy
firebase deploy --only functions
```

### "Permission Denied" Error
- Make sure you deployed the updated firestore.rules
- Check that `moderated: true` is set in the message

### Function Times Out
- Perspective API might be slow - increase timeout in functions/index.js:
```javascript
exports.moderateMessage = functions
  .runWith({ timeoutSeconds: 10 })
  .https.onCall(async (data, context) => {
```

### High API Costs
- Check usage at [Google Cloud Console](https://console.cloud.google.com) → Billing
- Set up budget alerts
- Consider caching results for duplicate messages

## Fallback Behavior

If the Perspective API is unavailable, the app uses a basic fallback filter to check for common profanity. This ensures chat continues to work even if the API has issues.

## Optional: Auto-Moderation on Write

The `autoModerateOnWrite` function automatically scans messages AFTER they're written to Firestore and deletes highly toxic ones. This is a backup layer in case client-side checks fail.

To enable auto-delete for toxic messages:
- It's already deployed with the functions
- Check logs at Firestore → moderationLogs collection

## Resources

- [Perspective API Documentation](https://developers.perspectiveapi.com/)
- [Firebase Functions Documentation](https://firebase.google.com/docs/functions)
- [Perspective API Pricing](https://developers.perspectiveapi.com/s/docs-pricing)

## Support

If you encounter issues:
1. Check Firebase Console → Functions → Logs
2. Check Xcode console for error messages
3. Verify API key is set: `firebase functions:config:get`
4. Ensure Firestore rules are deployed: `firebase deploy --only firestore:rules`
