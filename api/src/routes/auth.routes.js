const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// تسجيل مستخدم جديد
router.post('/register',
  [
    body('email').isEmail(),
    body('password').isLength({ min: 6 }),
    body('name').notEmpty(),
    body('phone').notEmpty(),
    body('role').isIn(['customer', 'restaurant', 'driver', 'admin'])
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { email, password, name, phone, role } = req.body;

      // إنشاء المستخدم في Firebase Auth
      const userRecord = await getAuth().createUser({
        email,
        password,
        displayName: name,
        phoneNumber: phone
      });

      // إنشاء وثيقة المستخدم في Firestore
      await db.collection('users').doc(userRecord.uid).set({
        name,
        email,
        phone,
        role,
        createdAt: new Date(),
        status: 'active'
      });

      res.status(201).json({
        message: 'User created successfully',
        userId: userRecord.uid
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// تسجيل الدخول
router.post('/login',
  [
    body('email').isEmail(),
    body('password').notEmpty()
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { email, password } = req.body;

      // التحقق من المستخدم في Firebase Auth
      const userCredential = await getAuth().getUserByEmail(email);
      
      // جلب بيانات المستخدم من Firestore
      const userDoc = await db.collection('users').doc(userCredential.uid).get();
      
      if (!userDoc.exists) {
        return res.status(404).json({ error: 'User not found' });
      }

      // إنشاء توكن المصادقة
      const token = await getAuth().createCustomToken(userCredential.uid);

      res.json({
        token,
        user: {
          id: userCredential.uid,
          ...userDoc.data()
        }
      });
    } catch (error) {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  }
);

// تحديث الملف الشخصي
router.put('/profile',
  async (req, res) => {
    try {
      const { userId } = req.user; // من middleware المصادقة
      const { name, phone, profileImage } = req.body;

      await db.collection('users').doc(userId).update({
        name,
        phone,
        profileImage,
        updatedAt: new Date()
      });

      res.json({ message: 'Profile updated successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

module.exports = router;