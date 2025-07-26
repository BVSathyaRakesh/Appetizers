# Appetizers Local API Server

A local server that provides the same API as the original Sean Allen course backend for the SwiftUI Appetizers app.

## Quick Start

1. **Install dependencies:**
   ```bash
   cd local-server
   npm install
   ```

2. **Start the server:**
   ```bash
   npm start
   ```

   For development with auto-restart:
   ```bash
   npm run dev
   ```

3. **Update your SwiftUI app:**
   
   In `NetworkManager.swift`, change the baseURL from:
   ```swift
   static let baseURL = "https://seanallen-course-backend.herokuapp.com/swiftui-fundamentals/"
   ```
   
   To:
   ```swift
   static let baseURL = "http://localhost:3000/swiftui-fundamentals/"
   ```

## API Endpoints

- **GET** `/swiftui-fundamentals/appetizers` - Returns list of appetizers
- **GET** `/health` - Server health check

## Server Info

- **Port:** 3000
- **Base URL:** `http://localhost:3000`
- **Appetizers Endpoint:** `http://localhost:3000/swiftui-fundamentals/appetizers`

## Adding Images

1. Place appetizer images in the `public/images/appetizers/` directory
2. Use the exact filenames referenced in the server data:
   - asian-flank-steak.jpg
   - buffalo-chicken-bites.jpg
   - chicken-avocado-spring-roll.jpg
   - chicken-tenders.jpg
   - fried-pickles.jpg
   - philly-cheesesteak-sliders.jpg
   - rainbow-spring-roll.jpg
   - spinach-dip.jpg
   - texas-cheese-fries.jpg

## Data Structure

The API returns data in this format:
```json
{
  "request": [
    {
      "id": 1,
      "name": "Asian Flank Steak",
      "description": "This perfectly thin cut just melts in your mouth.",
      "price": 8.99,
      "imageURL": "http://localhost:3000/images/appetizers/asian-flank-steak.jpg",
      "calories": 300,
      "protein": 14,
      "carbs": 0
    }
  ]
}
```

## Notes

- CORS is enabled for cross-origin requests
- Images are served statically from `/images` endpoint
- The server matches the exact data structure expected by the SwiftUI app 