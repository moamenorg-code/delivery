// src/config/config.js
require('dotenv').config();

const config = {
  env: process.env.NODE_ENV || 'development',
  port: process.env.PORT || 3000,
  
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL
  },
  
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d'
  },
  
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY,
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET
  },
  
  email: {
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  },
  
  redis: {
    url: process.env.REDIS_URL
  }
};

// التحقق من التكوين المطلوب
const requiredConfig = [
  'firebase.projectId',
  'firebase.privateKey',
  'firebase.clientEmail',
  'jwt.secret'
];

requiredConfig.forEach(path => {
  const value = path.split('.').reduce((obj, key) => obj?.[key], config);
  if (!value) {
    throw new Error(`Missing required config: ${path}`);
  }
});

module.exports = config;