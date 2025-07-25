# 📱 Get Your 60-Day Instagram Access Token - Step by Step

## 🚀 Step 1: Access Facebook Developer Console

1. **Open your browser** and go to: https://developers.facebook.com/apps
2. **Sign in** with your Facebook account
3. **Find your app** (or create one if you don't have one)

---

## 🔧 Step 2: Get Your App Credentials

1. **Click on your app** in the list
2. **Go to Settings → Basic** (left sidebar)
3. **Copy these values:**
   - **App ID**: Copy this number
   - **App Secret**: Click "Show" and copy this value

📝 **Save these safely** - you'll need them for the automatic refresh system!

---

## 📊 Step 3: Use Graph API Explorer

1. **Go to Graph API Explorer**: https://developers.facebook.com/tools/explorer/
2. **Select your app** from the dropdown (top right)
3. **Click "Generate Access Token"**
4. **Select these permissions:**
   - ✅ `instagram_basic`
   - ✅ `pages_show_list`
   - ✅ `pages_read_engagement`
5. **Click "Generate Access Token"**
6. **Copy the token** that appears (this is your short-lived token)

---

## ⏰ Step 4: Exchange for 60-Day Token

**Important**: The short-lived token expires in 1 hour, so do this step immediately!

### Option A: Use the Script I Created

```bash
# Edit the script with your values
nano get_long_lived_token.sh

# Replace these lines with your actual values:
APP_ID="YOUR_APP_ID_FROM_STEP_2"
APP_SECRET="YOUR_APP_SECRET_FROM_STEP_2"
SHORT_LIVED_TOKEN="YOUR_TOKEN_FROM_STEP_3"

# Run the script
./get_long_lived_token.sh
```

### Option B: Manual cURL Command

```bash
curl -X GET "https://graph.facebook.com/v19.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=YOUR_SHORT_LIVED_TOKEN"
```

**Replace**:
- `YOUR_APP_ID` → from Step 2
- `YOUR_APP_SECRET` → from Step 2  
- `YOUR_SHORT_LIVED_TOKEN` → from Step 3

---

## ✅ Step 5: Get Your 60-Day Token

You should get a response like this:

```json
{
  "access_token": "EAAOzNS0ZAF6wBPMIgf...",
  "token_type": "bearer", 
  "expires_in": 5183999
}
```

🎉 **The `access_token` is your 60-day token!**
📅 **`expires_in: 5183999`** = 60 days in seconds

---

## 🔧 Step 6: Update Your App

**Edit `Gorby/Services/InstagramService.swift`:**

```swift
// Replace these lines:
private let appId = "YOUR_APP_ID_FROM_STEP_2"
private let appSecret = "YOUR_APP_SECRET_FROM_STEP_2"

// And this line:
UserDefaults.standard.string(forKey: tokenKey) ?? "YOUR_60_DAY_TOKEN_FROM_STEP_5"
```

---

## 🧪 Step 7: Test Your Token

Test that your token works:

```bash
curl -s "https://graph.facebook.com/v19.0/17897324478249053/recent_media?user_id=17841400370020314&fields=id,caption,media_type,media_url,permalink&access_token=YOUR_60_DAY_TOKEN"
```

✅ **Success**: You should see actual Instagram data
❌ **Error**: Check your token and try again

---

## 🎯 Step 8: Initialize in Your App

**Add this to your app startup** (in `GorbyApp.swift` or first view):

```swift
// Run this ONCE when you first set up the token
let instagramService = InstagramService()
instagramService.initializeToken("YOUR_60_DAY_TOKEN", expiresIn: 5183999)
```

---

## 🎊 You're Done!

Your Instagram integration will now:
- ✅ Work for 60 days automatically
- ✅ Auto-refresh 5 days before expiration  
- ✅ Handle token expiration gracefully
- ✅ Never require manual intervention again!

## 🚨 Important Notes

1. **Keep App Secret secure** - never commit to git
2. **60-day tokens are the maximum** - this is Instagram's limit
3. **Auto-refresh handles everything** - you don't need to do this again
4. **Production apps** should use server-side token management

---

## 🆘 Troubleshooting

### "Access token expired" error:
- Your short-lived token expired (1 hour limit)
- Go back to Step 3 and get a new one

### "Invalid permissions" error:  
- Make sure you selected the right permissions in Step 3
- Try again with `instagram_basic` permission

### "App not found" error:
- Double-check your App ID in Step 2
- Make sure you're using the right app

### Still stuck?
- Check the console logs for detailed error messages
- The debug info will tell you exactly what's wrong!

---

**Need help?** Let me know what step you're stuck on! 🚀
