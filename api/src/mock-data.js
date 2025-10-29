const mockData = {
  restaurants: [
    {
      id: "rest1",
      name: "مطعم الشرق",
      description: "مأكولات شرقية تقليدية",
      image: "https://picsum.photos/200",
      rating: 4.5,
      location: {
        lat: 31.9539,
        lng: 35.9106
      },
      address: "شارع الملك عبدالله الثاني، عمان",
      cuisine: "شرقي",
      menu: [
        {
          id: "item1",
          name: "شاورما دجاج",
          description: "شاورما دجاج مع صوص خاص",
          price: 3.5,
          image: "https://picsum.photos/200"
        },
        {
          id: "item2",
          name: "مشاوي مشكل",
          description: "تشكيلة من المشاوي العربية",
          price: 15.0,
          image: "https://picsum.photos/200"
        }
      ]
    },
    {
      id: "rest2",
      name: "برجر هاوس",
      description: "أشهى البرجر الطازج",
      image: "https://picsum.photos/200",
      rating: 4.2,
      location: {
        lat: 31.9522,
        lng: 35.9283
      },
      address: "شارع الجامعة، عمان",
      cuisine: "برجر",
      menu: [
        {
          id: "item3",
          name: "برجر كلاسيك",
          description: "برجر لحم مع جبنة وخضار",
          price: 5.0,
          image: "https://picsum.photos/200"
        }
      ]
    }
  ],
  
  orders: [
    {
      id: "order1",
      restaurantId: "rest1",
      customerId: "cust1",
      items: [
        {
          id: "item1",
          quantity: 2,
          price: 3.5
        }
      ],
      status: "ready_for_pickup",
      total: 7.0,
      deliveryFee: 2.0,
      customerLocation: {
        lat: 31.9539,
        lng: 35.9206
      },
      restaurantLocation: {
        lat: 31.9539,
        lng: 35.9106
      },
      createdAt: new Date().toISOString()
    }
  ],
  
  drivers: [
    {
      id: "driver1",
      name: "أحمد محمد",
      phone: "+962791234567",
      email: "ahmed@example.com",
      status: "available",
      currentLocation: {
        lat: 31.9539,
        lng: 35.9150
      },
      rating: 4.8,
      totalDeliveries: 150,
      earnings: [
        {
          orderId: "order1",
          amount: 1.6,
          createdAt: new Date().toISOString()
        }
      ]
    }
  ],
  
  users: [
    {
      id: "cust1",
      name: "سارة أحمد",
      email: "sara@example.com",
      phone: "+962797654321",
      addresses: [
        {
          id: "addr1",
          title: "المنزل",
          location: {
            lat: 31.9539,
            lng: 35.9206
          },
          address: "شارع الملك حسين، عمان"
        }
      ]
    }
  ]
};

module.exports = mockData;