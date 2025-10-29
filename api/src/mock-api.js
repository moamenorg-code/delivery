const express = require('express');
const cors = require('cors');
const mockData = require('./mock-data');

const app = express();
const port = 3001; // نستخدم منفذ مختلف عن الـ API الرئيسي

app.use(cors());
app.use(express.json());

// ميدلوير للمصادقة الوهمية
const mockAuth = (req, res, next) => {
  const token = req.headers.authorization;
  if (!token) {
    return res.status(401).json({ error: 'غير مصرح' });
  }
  // نضيف معرف المستخدم للطلب
  req.user = { userId: 'cust1' };
  next();
};

// المطاعم
app.get('/api/restaurants', (req, res) => {
  const { lat, lng, radius } = req.query;
  let restaurants = mockData.restaurants;
  
  if (lat && lng && radius) {
    restaurants = restaurants.filter(restaurant => {
      const distance = calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        restaurant.location.lat,
        restaurant.location.lng
      );
      return distance <= parseFloat(radius);
    });
  }
  
  res.json(restaurants);
});

app.get('/api/restaurants/:id', (req, res) => {
  const restaurant = mockData.restaurants.find(r => r.id === req.params.id);
  if (!restaurant) {
    return res.status(404).json({ error: 'المطعم غير موجود' });
  }
  res.json(restaurant);
});

// الطلبات
app.get('/api/orders', mockAuth, (req, res) => {
  const { status } = req.query;
  let orders = mockData.orders.filter(o => o.customerId === req.user.userId);
  
  if (status) {
    orders = orders.filter(o => o.status === status);
  }
  
  res.json(orders);
});

app.post('/api/orders', mockAuth, (req, res) => {
  const newOrder = {
    id: \`order\${mockData.orders.length + 1}\`,
    customerId: req.user.userId,
    ...req.body,
    status: 'pending',
    createdAt: new Date().toISOString()
  };
  mockData.orders.push(newOrder);
  res.status(201).json(newOrder);
});

// المندوبين
app.get('/api/drivers/available', (req, res) => {
  const { lat, lng } = req.query;
  let drivers = mockData.drivers.filter(d => d.status === 'available');
  
  if (lat && lng) {
    drivers = drivers.map(driver => ({
      ...driver,
      distance: calculateDistance(
        parseFloat(lat),
        parseFloat(lng),
        driver.currentLocation.lat,
        driver.currentLocation.lng
      )
    })).sort((a, b) => a.distance - b.distance);
  }
  
  res.json(drivers);
});

app.post('/api/drivers/location', mockAuth, (req, res) => {
  const driver = mockData.drivers.find(d => d.id === req.user.userId);
  if (!driver) {
    return res.status(404).json({ error: 'المندوب غير موجود' });
  }
  driver.currentLocation = req.body.location;
  res.json({ message: 'تم تحديث الموقع بنجاح' });
});

// المستخدمين
app.get('/api/users/profile', mockAuth, (req, res) => {
  const user = mockData.users.find(u => u.id === req.user.userId);
  if (!user) {
    return res.status(404).json({ error: 'المستخدم غير موجود' });
  }
  res.json(user);
});

app.patch('/api/users/profile', mockAuth, (req, res) => {
  const user = mockData.users.find(u => u.id === req.user.userId);
  if (!user) {
    return res.status(404).json({ error: 'المستخدم غير موجود' });
  }
  Object.assign(user, req.body);
  res.json(user);
});

// المصادقة
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  const user = mockData.users.find(u => u.email === email);
  
  if (!user) {
    return res.status(401).json({ error: 'بيانات غير صحيحة' });
  }
  
  res.json({
    token: 'mock-token-123',
    user
  });
});

app.post('/api/auth/register', (req, res) => {
  const { email, password, name, phone } = req.body;
  
  if (mockData.users.some(u => u.email === email)) {
    return res.status(400).json({ error: 'البريد الإلكتروني مستخدم بالفعل' });
  }
  
  const newUser = {
    id: \`user\${mockData.users.length + 1}\`,
    email,
    name,
    phone,
    addresses: []
  };
  
  mockData.users.push(newUser);
  
  res.status(201).json({
    token: 'mock-token-123',
    user: newUser
  });
});

// دالة لحساب المسافة بين نقطتين
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // نصف قطر الأرض بالكيلومترات
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function toRad(deg) {
  return deg * Math.PI / 180;
}

app.listen(port, () => {
  console.log(\`Mock API server running on port \${port}\`);
});