const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const { getFirestore } = require('firebase-admin/firestore');

const db = getFirestore();

// جلب قائمة المطاعم
router.get('/', async (req, res) => {
  try {
    const { category, query, lat, lng, radius } = req.query;
    let restaurantsRef = db.collection('restaurants');

    if (category) {
      restaurantsRef = restaurantsRef.where('categories', 'array-contains', category);
    }

    const snapshot = await restaurantsRef.get();
    const restaurants = [];

    snapshot.forEach(doc => {
      restaurants.push({
        id: doc.id,
        ...doc.data()
      });
    });

    // تصفية حسب البحث
    if (query) {
      const searchQuery = query.toLowerCase();
      return res.json(restaurants.filter(restaurant => 
        restaurant.name.toLowerCase().includes(searchQuery) ||
        restaurant.description.toLowerCase().includes(searchQuery)
      ));
    }

    // تصفية حسب الموقع
    if (lat && lng && radius) {
      const userLocation = { lat: parseFloat(lat), lng: parseFloat(lng) };
      return res.json(restaurants.filter(restaurant => 
        isWithinRadius(restaurant.location, userLocation, parseFloat(radius))
      ));
    }

    res.json(restaurants);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// إضافة مطعم جديد
router.post('/',
  [
    body('name').notEmpty(),
    body('description').notEmpty(),
    body('categories').isArray(),
    body('location').isObject(),
  ],
  async (req, res) => {
    try {
      const restaurantData = {
        ...req.body,
        createdAt: new Date(),
        rating: 0,
        reviewsCount: 0,
        isOpen: false
      };

      const docRef = await db.collection('restaurants').add(restaurantData);
      
      res.status(201).json({
        id: docRef.id,
        ...restaurantData
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  }
);

// تحديث معلومات المطعم
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = {
      ...req.body,
      updatedAt: new Date()
    };

    await db.collection('restaurants').doc(id).update(updateData);
    
    res.json({ message: 'Restaurant updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// إضافة منتج للقائمة
router.post('/:id/menu', async (req, res) => {
  try {
    const { id } = req.params;
    const menuItem = {
      ...req.body,
      createdAt: new Date()
    };

    const docRef = await db.collection('restaurants').doc(id)
      .collection('menu').add(menuItem);
    
    res.status(201).json({
      id: docRef.id,
      ...menuItem
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// تحديث حالة المطعم (مفتوح/مغلق)
router.patch('/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { isOpen } = req.body;

    await db.collection('restaurants').doc(id).update({
      isOpen,
      updatedAt: new Date()
    });
    
    res.json({ message: 'Restaurant status updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// حساب المسافة بين نقطتين
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