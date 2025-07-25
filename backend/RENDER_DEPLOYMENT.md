# 🚀 Gorby Backend - Render Deployment Guide

## ✅ Prerequisites
- GitHub account with your Gorby repository
- OpenAI API key (get from [platform.openai.com/api-keys](https://platform.openai.com/api-keys))

## 🌐 Deploy to Render (FREE)

### Step 1: Go to Render
1. Visit **[render.com](https://render.com)**
2. Click **"Get Started for Free"**
3. Sign up with your GitHub account

### Step 2: Create New Web Service
1. Click **"New +"** in the top right
2. Select **"Web Service"**
3. Connect your GitHub account if prompted
4. Find and select your **Gorby repository**

### Step 3: Configure Deployment
**Repository Settings:**
- **Root Directory**: `backend` (important!)
- **Branch**: `main` (or whatever your default branch is)

**Build & Deploy Settings:**
- **Environment**: `Node`
- **Build Command**: `npm install`
- **Start Command**: `npm start`
- **Instance Type**: **Free** (make sure this is selected!)

### Step 4: Add Environment Variables
In the "Environment Variables" section, add these:

```
OPENAI_API_KEY = your_actual_openai_api_key_here
NODE_ENV = production
CACHE_DURATION_MINUTES = 7
SCRAPING_TIMEOUT_MS = 30000
LOG_LEVEL = info
```

⚠️ **CRITICAL**: You MUST add your real OpenAI API key or the lift scraping won't work!

### Step 5: Deploy!
1. Click **"Create Web Service"**
2. Render will start building and deploying
3. This takes 2-3 minutes the first time

### Step 6: Get Your URL
After deployment, you'll get a URL like:
```
https://gorby-backend-xyz123.onrender.com
```

Copy this URL - you'll need it for the next step!

## 📱 Update iOS App

### Step 7: Update Production URL
1. Open `Gorby/Services/LiftStatusService.swift`
2. Find this line:
   ```swift
   return "https://gorby-backend.onrender.com/api"
   ```
3. Replace it with YOUR actual Render URL:
   ```swift
   return "https://YOUR-ACTUAL-URL.onrender.com/api"
   ```

## 🧪 Test Your Deployment

### Step 8: Test Endpoints
Open these URLs in your browser (replace with your actual URL):

1. **Health Check**: `https://your-url.onrender.com/health`
   - Should return: `{"status": "healthy", "timestamp": "..."}`

2. **Lift Status**: `https://your-url.onrender.com/api/lifts`
   - Should return JSON with lift data

3. **Webcams**: `https://your-url.onrender.com/api/webcams`
   - Should return JSON with webcam data

### Step 9: Test iOS App
1. Build your iOS app in **Release mode**:
   ```bash
   cd /Users/chachi/Desktop/APPS/Gorby
   xcodebuild -project Gorby.xcodeproj -scheme Gorby -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' build
   ```
2. Run the app and check the Lift Status page
3. Should show live data instead of fallback data!

## 🎉 Success Indicators

✅ **Backend deployed successfully**
✅ **Health endpoint responding**
✅ **API endpoints returning data**
✅ **iOS app connecting to production**
✅ **No more fallback data in app**

## 🔧 Troubleshooting

**If deployment fails:**
- Check that `backend` is set as root directory
- Verify all environment variables are set
- Check build logs in Render dashboard

**If app shows fallback data:**
- Verify you updated the production URL in iOS app
- Check that you're building in Release mode (not Debug)
- Test API endpoints directly in browser first

**If scraping isn't working:**
- Verify your OpenAI API key is correct
- Check logs in Render dashboard for errors
- Make sure you have OpenAI credits available

## 💰 Render Free Tier Details

- **750 hours/month** (enough for 24/7 operation)
- **512MB RAM** (sufficient for your app)
- **Sleeps after 15 min idle** (but your auto-refresh every 7 min keeps it awake!)
- **Automatic HTTPS**
- **No credit card required**

## 🔄 Automatic Deployments

Every time you push to GitHub, Render will automatically redeploy your backend!

---

## 📞 Need Help?

If you run into any issues:
1. Check the Render dashboard logs
2. Verify all environment variables are set
3. Test endpoints manually in browser
4. Make sure OpenAI API key is valid and has credits 