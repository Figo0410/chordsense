
const https = require('https');

const sendEmail = async ({ to, subject, html }) => {
  if (!process.env.BREVO_API_KEY) {
    throw new Error('Missing BREVO_API_KEY environment variable');
  }

  if (!process.env.BREVO_SENDER_EMAIL) {
    throw new Error('Missing BREVO_SENDER_EMAIL environment variable');
  }

  const data = JSON.stringify({
    sender: {
      email: process.env.BREVO_SENDER_EMAIL,
      name: process.env.BREVO_SENDER_NAME || 'ChordSense Support'
    },
    to: [{ email: to }],
    subject,
    htmlContent: html
  });

  const options = {
    hostname: 'api.brevo.com',
    path: '/v3/smtp/email',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'api-key': process.env.BREVO_API_KEY,
      'Content-Length': Buffer.byteLength(data)
    },
    timeout: 15000
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';

      res.on('data', (chunk) => {
        body += chunk;
      });

      res.on('end', () => {
        console.log('[Brevo] HTTP status:', res.statusCode);

        if (res.statusCode >= 200 && res.statusCode < 300) {
          let responseBody;

          try {
            responseBody = body ? JSON.parse(body) : {};
          } catch {
            responseBody = {};
          }

          console.log('[Brevo] Message ID:', responseBody.messageId || 'Not returned');

          resolve(responseBody);
        } else {
          console.error('[Brevo] API error:', res.statusCode, body);
          reject(new Error(`Brevo API Error: ${res.statusCode} - ${body}`));
        }
      });
    });

    req.on('timeout', () => {
      req.destroy(new Error('Brevo request timed out'));
    });

    req.on('error', (error) => {
      console.error('[Brevo] Request failed:', error.message);
      reject(error);
    });

    req.write(data);
    req.end();
  });
};

module.exports = { sendEmail };
