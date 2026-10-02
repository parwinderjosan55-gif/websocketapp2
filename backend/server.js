const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Download your Service Account Key from Firebase Console:
// Project Settings -> Service accounts -> Generate new private key
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Endpoint to send push notifications
app.post('/send-notification', async (req, res) => {
  const { token, title, body } = req.body;

  if (!token || !title || !body) {
    return res.status(400).send({ error: 'Missing token, title, or body' });
  }

  const message = {
    token: token,
    notification: {
      title: title,
      body: body,
    },
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        channelId: 'important_message_channel',
        priority: 'high',
        visibility: 'public'
      }
    },
    apns: {
      payload: {
        aps: {
          sound: 'default'
        }
      }
    },
    data: {
      title: title,
      body: body,
      click_action: 'FLUTTER_NOTIFICATION_CLICK'
    }
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Successfully sent message:', response);
    res.status(200).send({ success: true, messageId: response });
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).send({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});