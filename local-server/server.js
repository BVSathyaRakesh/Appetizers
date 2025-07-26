const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Serve static images
app.use('/images', express.static('public/images'));

// Sample appetizer data matching the Swift model structure
const appetizersData = [
  {
    id: 1,
    name: "Asian Flank Steak",
    description: "This perfectly thin cut just melts in your mouth.",
    price: 8.99,
    imageURL: "http://localhost:3000/images/appetizers/asian-flank-steak.jpg",
    calories: 300,
    protein: 14,
    carbs: 0
  },
  {
    id: 2,
    name: "Buffalo Chicken Bites",
    description: "Buffalicious bites of chicken & joy.",
    price: 5.99,
    imageURL: "http://localhost:3000/images/appetizers/buffalo-chicken-bites.jpg",
    calories: 280,
    protein: 12,
    carbs: 8
  },
  {
    id: 3,
    name: "Chicken Avocado Spring Roll",
    description: "These won't last 10 minutes once they hit the table.",
    price: 6.99,
    imageURL: "http://localhost:3000/images/appetizers/chicken-avocado-spring-roll.jpg",
    calories: 270,
    protein: 18,
    carbs: 15
  },
  {
    id: 4,
    name: "Chicken Tenders",
    description: "Our bettered and fried chicken tenders are a customer favorite.",
    price: 8.99,
    imageURL: "http://localhost:3000/images/appetizers/chicken-tenders.jpg",
    calories: 450,
    protein: 32,
    carbs: 12
  },
  {
    id: 5,
    name: "Fried Pickles",
    description: "Who doesn't love a good pickle? Fried pickle to be exact.",
    price: 4.99,
    imageURL: "http://localhost:3000/images/appetizers/fried-pickles.jpg",
    calories: 290,
    protein: 6,
    carbs: 25
  },
  {
    id: 6,
    name: "Philly Cheesesteak Sliders",
    description: "Philly's finest on a mini bun. It will have you coming back for more.",
    price: 9.99,
    imageURL: "http://localhost:3000/images/appetizers/philly-cheesesteak-sliders.jpg",
    calories: 520,
    protein: 28,
    carbs: 35
  },
  {
    id: 7,
    name: "Rainbow Spring Roll",
    description: "It's like eating a rainbow! So many flavors in one bite.",
    price: 7.99,
    imageURL: "http://localhost:3000/images/appetizers/rainbow-spring-roll.jpg",
    calories: 200,
    protein: 8,
    carbs: 20
  },
  {
    id: 8,
    name: "Spinach Dip",
    description: "Warm cheese and spinach dip served with fresh tortilla chips.",
    price: 5.99,
    imageURL: "http://localhost:3000/images/appetizers/spinach-dip.jpg",
    calories: 350,
    protein: 12,
    carbs: 18
  },
  {
    id: 9,
    name: "Texas Cheese Fries",
    description: "Lone Star's spin on loaded cheese fries with shredded brisket.",
    price: 8.99,
    imageURL: "http://localhost:3000/images/appetizers/texas-cheese-fries.jpg",
    calories: 450,
    protein: 22,
    carbs: 28
  }
];

// API Routes
app.get('/swiftui-fundamentals/appetizers', (req, res) => {
  try {
    // Return data in the expected format matching AppetizerResponse structure
    const response = {
      request: appetizersData
    };
    
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'Server is running', timestamp: new Date().toISOString() });
});

// Start server
app.listen(PORT, () => {
  console.log(`🍴 Appetizers API Server running on http://localhost:${PORT}`);
  console.log(`📱 Appetizers endpoint: http://localhost:${PORT}/swiftui-fundamentals/appetizers`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
}); 