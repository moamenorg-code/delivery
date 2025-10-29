const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// تحديث موقع المندوب
router.post('/location',
  [
    body('location').isObject()
  ],
  async (req, res) => {
    try {
      const { userId } = req.user;
      const { location } = req.body;

      await db.collection('drivers').doc(userId).update({
        currentLocation: location,
        lastLocationUpdate: new Date()
      });

      res.json({ message: 'Location updated successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// تحديث حالة المندوب
router.patch('/status',
  [
    body('status').isIn(['available', 'busy', 'offline'])
  ],
  async (req, res) => {
    try {
      const { userId } = req.user;
      const { status } = req.body;

      await db.collection('drivers').doc(userId).update({
        status,
        updatedAt: new Date()
      });

      res.json({ message: 'Status updated successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// جلب الطلبات المتاحة للتوصيل
router.get('/available-orders', async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;
    const snapshot = await db.collection('orders')
      .where('status', '==', 'ready_for_pickup')
      .where('driverId', '==', null)
      .get();

    const orders = [];
    snapshot.forEach(doc => {
      const order = {
        id: doc.id,
        ...doc.data()
      };

      // تصفية حسب الموقع إذا تم تحديده
      if (lat && lng && radius) {
        const userLocation = { lat: parseFloat(lat), lng: parseFloat(lng) };
        const restaurantLocation = order.restaurantLocation;
        
        if (isWithinRadius(restaurantLocation, userLocation, parseFloat(radius))) {
          orders.push(order);
        }
      } else {
        orders.push(order);
      }
    });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// قبول طلب توصيل
router.post('/accept-order/:orderId',
  async (req, res) => {
    try {
      const { userId } = req.user;
      const { orderId } = req.params;

      // التحقق من حالة المندوب
      const driverDoc = await db.collection('drivers').doc(userId).get();
      if (!driverDoc.exists || driverDoc.data().status !== 'available') {
        return res.status(400).json({ error: 'Driver not available' });
      }

      // التحقق من حالة الطلب
      const orderDoc = await db.collection('orders').doc(orderId).get();
      if (!orderDoc.exists || orderDoc.data().status !== 'ready_for_pickup') {
        return res.status(400).json({ error: 'Order not available' });
      }

      // تحديث الطلب والمندوب
      await db.runTransaction(async (transaction) => {
        transaction.update(db.collection('orders').doc(orderId), {
          driverId: userId,
          status: 'picked_up',
          updatedAt: new Date()
        });

        transaction.update(db.collection('drivers').doc(userId), {
          status: 'busy',
          currentOrderId: orderId,
          updatedAt: new Date()
        });
      });

      res.json({ message: 'Order accepted successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// إكمال توصيل الطلب
router.post('/complete-delivery/:orderId',
  async (req, res) => {
    try {
      const { userId } = req.user;
      const { orderId } = req.params;

      // التحقق من الطلب والمندوب
      const orderDoc = await db.collection('orders').doc(orderId).get();
      if (!orderDoc.exists || orderDoc.data().driverId !== userId) {
        return res.status(403).json({ error: 'Not authorized' });
      }

      // تحديث حالة الطلب والمندوب
      await db.runTransaction(async (transaction) => {
        transaction.update(db.collection('orders').doc(orderId), {
          status: 'delivered',
          deliveredAt: new Date(),
          updatedAt: new Date()
        });

        transaction.update(db.collection('drivers').doc(userId), {
          status: 'available',
          currentOrderId: null,
          updatedAt: new Date()
        });

        // إضافة الأرباح للمندوب
        const order = orderDoc.data();
        const earnings = order.deliveryFee * 0.8; // 80% من رسوم التوصيل
        
        transaction.create(db.collection('drivers').doc(userId).collection('earnings').doc(), {
          orderId,
          amount: earnings,
          createdAt: new Date()
        });
      });

      res.json({ message: 'Delivery completed successfully' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// جلب إحصائيات المندوب
router.get('/statistics', async (req, res) => {
  try {
    const { userId } = req.user;
    const { startDate, endDate } = req.query;

    const start = startDate ? new Date(startDate) : new Date(new Date().setHours(0,0,0,0));
    const end = endDate ? new Date(endDate) : new Date(new Date().setHours(23,59,59,999));

    // جلب التوصيلات المكتملة
    const deliveriesSnapshot = await db.collection('orders')
      .where('driverId', '==', userId)
      .where('status', '==', 'delivered')
      .where('deliveredAt', '>=', start)
      .where('deliveredAt', '<=', end)
      .get();

    // جلب الأرباح
    const earningsSnapshot = await db.collection('drivers')
      .doc(userId)
      .collection('earnings')
      .where('createdAt', '>=', start)
      .where('createdAt', '<=', end)
      .get();

    let totalDeliveries = 0;
    let totalEarnings = 0;

    deliveriesSnapshot.forEach(() => {
      totalDeliveries++;
    });

    earningsSnapshot.forEach(doc => {
      totalEarnings += doc.data().amount;
    });

    res.json({
      totalDeliveries,
      totalEarnings,
      period: {
        start: start.toISOString(),
        end: end.toISOString()
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

function isWithinRadius(point1, point2, radius) {
  const R = 6371; // نصف قطر الأرض بالكيلومترات
  const dLat = toRad(point2.lat - point1.lat);
  const dLon = toRad(point2.lng - point1.lng);
  const lat1 = toRad(point1.lat);
  const lat2 = toRad(point2.lat);

  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  const d = R * c;
  
  return d <= radius;
}

function toRad(degrees) {
  return degrees * Math.PI / 180;
}

module.exports = router;