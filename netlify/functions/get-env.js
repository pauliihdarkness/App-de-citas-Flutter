/**
 * Netlify Function to expose environment variables to Flutter Web
 * Accessible at: /.netlify/functions/get-env
 */

exports.handler = async (event, context) => {
  try {
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
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
      },
      body: JSON.stringify(env),
    };
  } catch (error) {
    console.error('Error in get-env function:', error);
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({ error: 'Failed to get environment variables' }),
    };
  }
};
