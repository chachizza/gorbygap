# 🚀 Gorby Backend Deployment Guide

## Railway Deployment

### Prerequisites
- OpenAI API key (required for ChatGPT scraping)
- Railway account (free tier available)

### 1. Deploy to Railway

**Option A: Deploy from GitHub (Recommended)**
1. Push your code to GitHub
2. Connect Railway to your GitHub repository
3. Railway will auto-deploy

**Option B: Railway CLI**
```bash
npm install -g @railway/cli
railway login
railway init
railway up
```

### 2. Set Environment Variables in Railway

In your Railway dashboard, set these environment variables:

```
OPENAI_API_KEY=your_actual_openai_api_key
NODE_ENV=production
PORT=3001
CACHE_DURATION_MINUTES=7
SCRAPING_TIMEOUT_MS=30000
LOG_LEVEL=info
```

### 3. Get Your Production URL

After deployment, Railway will provide a URL like:
```
https://your-app-name.railway.app
```

### 4. Update iOS App

Update the production URL in your iOS app:
```swift
// In LiftStatusService.swift
return "https://your-app-name.railway.app/api"
```

### 5. Test Endpoints

- Health: `https://your-app-name.railway.app/health`
- Lifts: `https://your-app-name.railway.app/api/lifts`
- Webcams: `https://your-app-name.railway.app/api/webcams`

## Production Features

✅ **Auto-refresh every 7 minutes**
✅ **ChatGPT-powered lift status parsing**
✅ **Live webcam feeds**
✅ **Proper error handling and fallback data**
✅ **CORS enabled for mobile apps**
✅ **Health check endpoint**

## Monitoring

Railway provides built-in monitoring:
- View logs in Railway dashboard
- Monitor CPU/memory usage
- Track request metrics
- Set up alerts for downtime 