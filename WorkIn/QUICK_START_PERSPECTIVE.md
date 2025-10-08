# Quick Start: Enable Perspective API

Your Firebase project ID is: **workin-app-a8a42**

## Option 1: Direct Link (Easiest)

1. **Click this link**: https://console.cloud.google.com/apis/library/commentanalyzer.googleapis.com?project=workin-app-a8a42

2. **Make sure** "workin-app-a8a42" is shown at the top of the page

3. **Click "Enable"**

4. **Wait** ~30 seconds for it to enable

5. **Go to Credentials**:
   - Click "Credentials" in the left sidebar
   - Click "+ CREATE CREDENTIALS"
   - Select "API Key"
   - Copy the key (looks like: `AIza...`)

## Option 2: Manual Search

If the direct link doesn't work:

1. Go to: https://console.cloud.google.com

2. **Select your project** in the dropdown at the very top:
   - Click the project selector (currently shows a project name)
   - Find and click **workin-app-a8a42**

3. **Enable the API**:
   - In the left menu, click **APIs & Services** → **Library**
   - In the search box, type: `perspective` or `comment analyzer`
   - Click on **Perspective Comment Analyzer API**
   - Click **Enable**

4. **Create API Key**:
   - Go to **APIs & Services** → **Credentials**
   - Click **+ CREATE CREDENTIALS**
   - Select **API Key**
   - Copy the key

## Can't Find It?

The API might be called:
- "Perspective Comment Analyzer API"
- "Comment Analyzer API"
- "Perspective API"

Or try searching for: `commentanalyzer.googleapis.com`

## After You Get the API Key:

```bash
# In terminal:
cd "/Users/caidfoot/Cursor Projects/WorkIn"

# Login to Firebase
firebase login

# Set the API key
firebase functions:config:set perspective.key="PASTE_YOUR_KEY_HERE"

# Install dependencies
cd functions
npm install
cd ..

# Deploy functions
firebase deploy --only functions

# Deploy firestore rules
firebase deploy --only firestore:rules
```

## Verify It's Enabled

Go to: https://console.cloud.google.com/apis/dashboard?project=workin-app-a8a42

You should see **Perspective Comment Analyzer API** in the list of enabled APIs.

## Still Having Issues?

The Perspective API might not be available in all regions or might require approval. If you can't find it:

**Alternative**: Use the fallback moderation that's already in the code. The app will work without Perspective API, but won't be as sophisticated.

To use fallback only:
1. Don't deploy the Cloud Functions
2. The Swift code has a fallback that checks basic profanity
3. Chat will work, just with simpler filtering
