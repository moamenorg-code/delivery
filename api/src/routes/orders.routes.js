const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// إنشاء طلب جديد
router.post('/',
  [
    body('restaurantId').notEmpty(),
    body('items').isArray(),
    body('deliveryAddress').isObject()
  ],
  async (req, res) => {
    try {
      const { userId } = req.user; // من middleware المصادقة
      const orderData = {
        ...req.body,
        customerId: userId,
        status: 'pending',
        createdAt: new Date(),
        updatedAt: new Date()
      };

      // حساب السعر الإجمالي
      let subtotal = 0;
      for (const item of orderData.items) {
        const menuItem = await db.collection('restaurants')
          .doc(orderData.restaurantId)
          .collection('menu')
          .doc(item.id)
          .get();
        
        if (!menuItem.exists) {
          return res.status(404).json({ error: `Menu item ${item.id} not found` });
        }

        subtotal += menuItem.data().price * item.quantity;
      }

      // إضافة الضريبة ورسوم التوصيل
      const tax = subtotal * 0.15; // 15% ضريبة
      const deliveryFee = 10; // رسوم ثابتة للتوصيل
      const total = subtotal + tax + deliveryFee;

      orderData.subtotal = subtotal;
      orderData.tax = tax;
      orderData.deliveryFee = deliveryFee;
      orderData.total = total;

      const docRef = await db.collection('orders').add(orderData);
      
      res.status(201).json({
        id: docRef.id,
        ...orderData
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// جلب تفاصيل الطلب
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const orderDoc = await db.collection('orders').doc(id).get();

    if (!orderDoc.exists) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.json({
      id: orderDoc.id,
      ...orderDoc.data()
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// تحديث حالة الطلب
router.patch('/:id/status',
  [
    body('status').isIn(['pending', 'accepted', 'preparing', 'ready_for_pickup', 'picked_up', 'delivering', 'delivered', 'cancelled'])
  ],
  async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;

      await db.collection('orders').doc(id).update({
        status,
        updatedAt: new Date()
      });

      res.json({ message: 'Order status updated successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// تعيين مندوب للطلب
router.patch('/:id/assign-driver',
  [
    body('driverId').notEmpty()
  ],
  async (req, res) => {
    try {
      const { id } = req.params;
      const { driverId } = req.body;

      await db.collection('orders').doc(id).update({
        driverId,
        status: 'picked_up',
        updatedAt: new Date()
      });

      res.json({ message: 'Driver assigned successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// جلب طلبات المستخدم
router.get('/user/history', async (req, res) => {
  try {
    const { userId } = req.user;
    const snapshot = await db.collection('orders')
      .where('customerId', '==', userId)
      .orderBy('createdAt', 'desc')
      .get();

    const orders = [];
    snapshot.forEach(doc => {
      orders.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// إلغاء الطلب
router.post('/:id/cancel',
  async (req, res) => {
    try {
      const { id } = req.params;
      const { userId } = req.user;

      const orderDoc = await db.collection('orders').doc(id).get();
      if (!orderDoc.exists) {
        return res.status(404).json({ error: 'Order not found' });
      }

      const orderData = orderDoc.data();
      if (orderData.customerId !== userId) {
        return res.status(403).json({ error: 'Not authorized' });
      }

      if (!['pending', 'accepted'].includes(orderData.status)) {
        return res.status(400).json({ error: 'Order cannot be cancelled' });
      }

      await db.collection('orders').doc(id).update({
        status: 'cancelled',
        updatedAt: new Date(),
        cancelledAt: new Date(),
        cancelledBy: userId
      });

      res.json({ message: 'Order cancelled successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

module.exports = router;