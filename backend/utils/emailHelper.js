const https = require('https');

const sendEmail = async ({ to, subject, html }) => {
  const data = JSON.stringify({
    sender: {
      email: process.env.BREVO_SENDER_EMAIL || 'no-reply@chordsense.com',
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
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(body);
        } else {
          reject(new Error(`Brevo API Error: ${res.statusCode} - ${body}`));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(data);
    req.end();
  });
};

module.exports = { sendEmail };
