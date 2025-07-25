# Instagram Auto-Refresh Setup Guide

## 🚀 Quick Setup (5 steps)

### 1. Get Your App Credentials
- Go to https://developers.facebook.com/apps
- Click your app → Settings → Basic
- Copy your **App ID** and **App Secret**

### 2. Get Initial 60-Day Token
- Go to https://developers.facebook.com/tools/explorer/
- Select your app
- Generate token with permissions: `instagram_basic`, `pages_show_list`, `pages_read_engagement`
- Copy the token

### 3. Exchange for Long-Lived Token
```bash
# Run this in terminal (replace YOUR_* with actual values)
curl -X GET "https://graph.facebook.com/v19.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=YOUR_SHORT_LIVED_TOKEN"
```

### 4. Update Your App
Edit `Gorby/Services/InstagramService.swift`:
```swift
// Replace these lines:
private let appId = "YOUR_APP_ID"           // ← Your actual App ID
private let appSecret = "YOUR_APP_SECRET"   // ← Your actual App Secret

// And this line:
UserDefaults.standard.string(forKey: tokenKey) ?? "YOUR_INITIAL_60_DAY_TOKEN_HERE"
// ↑ Replace with your 60-day token
```

### 5. Initialize Token (Run Once)
Add this to your app startup or call it once:
```swift
// In your app startup (GorbyApp.swift or first view)
let instagramService = InstagramService()
instagramService.initializeToken("YOUR_60_DAY_TOKEN", expiresIn: 5183999) // 60 days
```

## ✨ What This System Does

### Automatic Features:
- 🔄 **Auto-refresh 5 days before expiration**
- 🚨 **Emergency refresh if token expires unexpectedly**
- 💾 **Secure token storage using UserDefaults**
- 📊 **Token status tracking**
- 🛡️ **Prevents duplicate refresh requests**

### Debug Features:
- 📱 **Token status display in app**
- 🔧 **Manual refresh button**
- 📝 **Detailed console logging**
- ⏰ **Days until expiration counter**

### Benefits:
- ✅ **Never manually refresh tokens again!**
- ✅ **60-day tokens auto-renewed every ~55 days**
- ✅ **Production ready**
- ✅ **Handles edge cases and errors**
- ✅ **Easy to debug and monitor**

## 🔧 Testing Your Setup

### Test Token Status:
Look for this in your app's Instagram section:
```
Token valid: ✅ | Days left: 58
```

### Test Manual Refresh:
Tap the "Refresh Token" button and check logs:
```
🔄 Instagram API: Starting token refresh...
✅ Instagram API: Token refreshed successfully! New expiration: [date]
```

### Test Automatic Refresh:
The system will automatically refresh when:
- 5 days before expiration (proactive)
- Immediately if API returns 190 error (reactive)

## 🚨 Important Security Notes

1. **Never commit App Secret to version control**
2. **Consider using environment variables for production**
3. **App Secret should only be used server-side in production**
4. **For production apps, implement server-side token refresh**

## 🎯 Production Recommendations

For a production app store release, consider:
1. **Server-side token management**
2. **Encrypted token storage (Keychain)**
3. **Environment-specific configurations**
4. **Error reporting/monitoring**

Your Instagram integration will now handle token expiration automatically! 🎉
