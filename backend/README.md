# Gorby Backend API

Backend API and scraping service for Gorby Gap - Live Whistler Blackcomb data

## 🚀 Features

- **Live Lift Status**: Real-time scraping from Whistler Peak using Puppeteer + OpenAI
- **Live Webcam Feeds**: Dynamic webcam data extraction from Whistler Blackcomb
- **Intelligent Parsing**: OpenAI GPT-4 powered HTML parsing for structured data
- **Auto-refresh**: Scheduled data updates every 7 minutes
- **Caching**: Smart caching to reduce scraping frequency
- **RESTful API**: Clean endpoints for Swift app integration

## 📋 Requirements

- Node.js 18.0.0 or higher
- OpenAI API key
- Internet connection for web scraping

## 🛠 Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Configuration

Copy the environment template:
```bash
cp env.example .env
```

Fill in your configuration in `.env`:
```env
# Required
OPENAI_API_KEY=your_openai_api_key_here

# Optional (defaults provided)
PORT=3001
HOST=localhost
CACHE_DURATION_MINUTES=10
SCRAPING_TIMEOUT_MS=30000
NODE_ENV=development
```

### 3. Get OpenAI API Key

1. Visit [OpenAI API](https://platform.openai.com/api-keys)
2. Create a new API key
3. Add it to your `.env` file

## 🚀 Usage

### Start the API Server

```bash
npm start
```

Server will run on `http://localhost:3001`

### Development Mode (with auto-restart)

```bash
npm run dev
```

### Manual Data Fetching

```bash
# Fetch lift status only
npm run fetch-lifts

# Fetch webcam data only  
npm run fetch-webcams

# Fetch all data sources
npm run fetch-all
```

## 📡 API Endpoints

### Live Lift Status
```
GET /api/lifts
```
Returns live lift status data:
```json
{
  "lastUpdated": "2025-01-24T15:30:00Z",
  "source": "whistlerpeak.com",
  "liftCount": 26,
  "lifts": [
    {
      "liftName": "Peak Express",
      "status": "Open",
      "mountain": "Whistler",
      "type": "Express Chair",
      "lastUpdated": "2025-01-24T15:30:00Z"
    }
  ]
}
```

### Live Webcam Feeds
```
GET /api/webcams
```
Returns webcam data:
```json
{
  "lastUpdated": "2025-01-24T15:30:00Z",
  "source": "whistlerblackcomb.com",
  "webcamCount": 8,
  "webcams": [
    {
      "name": "Roundhouse Lodge",
      "imageUrl": "https://example.com/camera1.jpg",
      "location": "Whistler Mountain",
      "isLive": true,
      "lastUpdated": "2025-01-24T15:30:00Z"
    }
  ]
}
```

### Combined Data
```
GET /api/all
```
Returns both lifts and webcams in single response.

### Manual Refresh
```
POST /api/lifts/refresh
POST /api/webcams/refresh
```

### Health Check
```
GET /health
```

## 🔄 Auto-Refresh

- **Frequency**: Every 7 minutes
- **Caching**: 10-minute cache duration (configurable)
- **Background Updates**: Smart background refresh when data is stale

## 📁 Data Storage

Data is stored in `/backend/data/`:
- `lifts.json` - Live lift status
- `webcams.json` - Webcam feed data
- `lifts-log.json` - Lift scraping logs
- `webcams-log.json` - Webcam scraping logs

## 🐛 Debugging

### Screenshots (Development Mode)
When `NODE_ENV=development`, screenshots are saved to:
- `data/lifts-screenshot.png`
- `data/webcams-screenshot.png`

### Logs
All operations are logged to console and log files in `/data/`.

## 🔗 Integration with Swift App

Update your Swift app's API client to point to:
```swift
let baseURL = "http://localhost:3001/api"
```

### Example Swift Integration:
```swift
// Fetch live lift data
func fetchLiveLifts() async throws -> LiftStatusResponse {
    let url = URL(string: "\(baseURL)/lifts")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(LiftStatusResponse.self, from: data)
}
```

## 🚧 Error Handling

- **Graceful Degradation**: API continues serving cached data if scraping fails
- **Retry Logic**: Automatic retry for failed requests
- **Logging**: Comprehensive error logging for debugging

## 📊 Performance

- **Puppeteer**: Headless browser for dynamic content
- **OpenAI**: Intelligent HTML parsing for reliable data extraction
- **Caching**: Reduces API calls and improves response times
- **Background Jobs**: Non-blocking data refresh

## 🔒 Security

- **Helmet**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: Built-in via caching mechanism
- **Environment Variables**: Secure API key storage

## 📈 Monitoring

Monitor the backend via:
- Health endpoint: `GET /health`
- Log files in `/data/`
- Console output for real-time status

---

**Following `.cursorrules`:**
- ✅ No mock data - All data is live and real-time
- ✅ Proper error handling and logging
- ✅ Documentation for all integrations
- ✅ Reliable data retrieval and parsing 