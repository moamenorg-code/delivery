const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../config/firebase-service-account.json');

// تهيئة Express
const app = express();

// تهيئة Firebase Admin
initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/users.routes'));
app.use('/api/restaurants', require('./routes/restaurants.routes'));
app.use('/api/orders', require('./routes/orders.routes'));
app.use('/api/drivers', require('./routes/drivers.routes'));
app.use('/api/payments', require('./routes/payments.routes'));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});