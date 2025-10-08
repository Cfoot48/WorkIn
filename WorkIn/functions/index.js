const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

/**
 * Moderate chat messages using Google's Perspective API
 * This function is called from the Swift app before sending a message
 */
exports.moderateMessage = functions.https.onCall(async (data, context) => {
  // Ensure user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send messages'
    );
  }

  const { message } = data;

  // Validate message
  if (!message || typeof message !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Message must be a non-empty string'
    );
  }

  if (message.length > 500) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Message must be 500 characters or less'
    );
  }

  try {
    // Get Perspective API key from config
    const perspectiveApiKey = functions.config().perspective?.key;

    if (!perspectiveApiKey) {
      console.error('Perspective API key not configured');
      // Fallback: allow message if API is not configured (for development)
      return {
        isAllowed: true,
        reason: '',
        scores: {}
      };
    }

    // Call Perspective API
    const response = await axios.post(
      `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${perspectiveApiKey}`,
      {
        comment: { text: message },
        languages: ['en'],
        requestedAttributes: {
          TOXICITY: {},
          SEVERE_TOXICITY: {},
          IDENTITY_ATTACK: {},
          INSULT: {},
          PROFANITY: {},
          THREAT: {},
          SEXUALLY_EXPLICIT: {},
          FLIRTATION: {}
        }
      }
    );

    const attributeScores = response.data.attributeScores;

    // Define thresholds for blocking
    const TOXICITY_THRESHOLD = 0.6;
    const SEVERE_TOXICITY_THRESHOLD = 0.5;
    const PROFANITY_THRESHOLD = 0.4;
    const THREAT_THRESHOLD = 0.6;
    const IDENTITY_ATTACK_THRESHOLD = 0.5;
    const INSULT_THRESHOLD = 0.6;
    const SEXUALLY_EXPLICIT_THRESHOLD = 0.6;

    let isAllowed = true;
    let reason = '';
    const flaggedCategories = [];

    // Check each attribute against its threshold
    if (attributeScores.TOXICITY?.summaryScore.value >= TOXICITY_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('toxic content');
    }
    if (attributeScores.SEVERE_TOXICITY?.summaryScore.value >= SEVERE_TOXICITY_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('severe toxicity');
    }
    if (attributeScores.PROFANITY?.summaryScore.value >= PROFANITY_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('profanity');
    }
    if (attributeScores.THREAT?.summaryScore.value >= THREAT_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('threats');
    }
    if (attributeScores.IDENTITY_ATTACK?.summaryScore.value >= IDENTITY_ATTACK_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('identity attack');
    }
    if (attributeScores.INSULT?.summaryScore.value >= INSULT_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('insults');
    }
    if (attributeScores.SEXUALLY_EXPLICIT?.summaryScore.value >= SEXUALLY_EXPLICIT_THRESHOLD) {
      isAllowed = false;
      flaggedCategories.push('sexually explicit');
    }

    if (!isAllowed) {
      reason = `Message blocked: Contains ${flaggedCategories.join(', ')}`;
    }

    // Log moderation decision
    console.log('Perspective API Moderation:', {
      userId: context.auth.uid,
      isAllowed,
      categories: flaggedCategories,
      messagePreview: message.substring(0, 50),
      scores: {
        toxicity: attributeScores.TOXICITY?.summaryScore.value,
        profanity: attributeScores.PROFANITY?.summaryScore.value,
        threat: attributeScores.THREAT?.summaryScore.value
      }
    });

    return {
      isAllowed,
      reason,
      scores: {
        toxicity: attributeScores.TOXICITY?.summaryScore.value,
        profanity: attributeScores.PROFANITY?.summaryScore.value,
        threat: attributeScores.THREAT?.summaryScore.value,
        severeToxicity: attributeScores.SEVERE_TOXICITY?.summaryScore.value,
        identityAttack: attributeScores.IDENTITY_ATTACK?.summaryScore.value,
        insult: attributeScores.INSULT?.summaryScore.value,
        sexuallyExplicit: attributeScores.SEXUALLY_EXPLICIT?.summaryScore.value
      }
    };

  } catch (error) {
    console.error('Perspective API error:', error.response?.data || error.message);

    // If Perspective API fails, block the message to be safe
    return {
      isAllowed: false,
      reason: 'Unable to verify message safety',
      scores: {}
    };
  }
});

/**
 * Alternative: Automatically moderate messages on write
 * This runs after a message is written to Firestore and can delete/flag it
 */
exports.autoModerateOnWrite = functions.firestore
  .document('globalChat/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();

    // Skip if already moderated by client
    if (message.moderated) {
      return null;
    }

    const messageText = message.message;
    const perspectiveApiKey = functions.config().perspective?.key;

    if (!perspectiveApiKey) {
      console.warn('Perspective API key not configured, skipping auto-moderation');
      return null;
    }

    try {
      const response = await axios.post(
        `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${perspectiveApiKey}`,
        {
          comment: { text: messageText },
          languages: ['en'],
          requestedAttributes: {
            TOXICITY: {},
            SEVERE_TOXICITY: {},
            IDENTITY_ATTACK: {},
            PROFANITY: {},
            THREAT: {},
            SEXUALLY_EXPLICIT: {}
          }
        }
      );

      const attributeScores = response.data.attributeScores;

      // Delete message if it exceeds thresholds
      const shouldDelete =
        attributeScores.SEVERE_TOXICITY?.summaryScore.value >= 0.5 ||
        attributeScores.THREAT?.summaryScore.value >= 0.6 ||
        attributeScores.IDENTITY_ATTACK?.summaryScore.value >= 0.5 ||
        attributeScores.PROFANITY?.summaryScore.value >= 0.4 ||
        attributeScores.SEXUALLY_EXPLICIT?.summaryScore.value >= 0.6;

      if (shouldDelete) {
        console.log('Deleting violating message:', {
          messageId: context.params.messageId,
          userId: message.userId,
          scores: attributeScores
        });

        await snap.ref.delete();

        // Log violation to a separate collection
        await admin.firestore().collection('moderationLogs').add({
          messageId: context.params.messageId,
          userId: message.userId,
          message: messageText,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          scores: attributeScores,
          action: 'deleted'
        });
      }

      return null;
    } catch (error) {
      console.error('Auto-moderation error:', error.message);
      return null;
    }
  });
