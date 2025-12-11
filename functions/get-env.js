// Netlify Function to expose environment variables to Flutter Web
// This function injects env vars into the HTML response

exports.handler = async (event, context) => {
  // Get environment variables
  const env = {
    FIREBASE_WEB_API_KEY: process.env.FIREBASE_WEB_API_KEY || '',
    FIREBASE_WEB_APP_ID: process.env.FIREBASE_WEB_APP_ID || '',
    FIREBASE_MESSAGING_SENDER_ID: process.env.FIREBASE_MESSAGING_SENDER_ID || '',
    FIREBASE_PROJECT_ID: process.env.FIREBASE_PROJECT_ID || '',
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify(env),
  };
};
