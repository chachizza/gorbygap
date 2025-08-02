# Security Configuration Guide

This document explains how to securely configure API credentials and sensitive data for the Gorby app.

## Overview

The app now uses a centralized `Configuration.swift` class to manage all API credentials and sensitive configuration data. This provides better security than hardcoded values.

## Current Configuration System

### **Configuration.swift**
- Central configuration manager
- Reads from multiple secure sources in priority order
- Validates credentials and warns about fallback values
- Supports environment-specific configurations

### **Priority Order for Credentials:**
1. **Info.plist keys** (recommended for iOS apps)
2. **Environment variables** (useful for development)
3. **Fallback values** (temporary - should be removed in production)

## Setting Up Secure Credentials

### **Method 1: Info.plist Configuration (Recommended)**

Add these keys to your `Gorby/Info.plist`:

```xml
<key>INSTAGRAM_APP_ID</key>
<string>YOUR_ACTUAL_APP_ID</string>
<key>INSTAGRAM_APP_SECRET</key>
<string>YOUR_ACTUAL_APP_SECRET</string>
<key>INSTAGRAM_USER_ID</key>
<string>YOUR_ACTUAL_USER_ID</string>
<key>INSTAGRAM_MEDIA_ID</key>
<string>YOUR_ACTUAL_MEDIA_ID</string>
```

### **Method 2: Build Configuration**

For better security, use Xcode build configurations:

1. **Go to Project Settings → Build Settings**
2. **Add User-Defined Settings:**
   - `INSTAGRAM_APP_ID`
   - `INSTAGRAM_APP_SECRET`
   - `INSTAGRAM_USER_ID`
   - `INSTAGRAM_MEDIA_ID`

3. **Update Info.plist to reference build settings:**
```xml
<key>INSTAGRAM_APP_ID</key>
<string>$(INSTAGRAM_APP_ID)</string>
```

### **Method 3: Environment Variables (Development)**

Set environment variables in Xcode scheme:
1. **Product → Scheme → Edit Scheme**
2. **Run → Arguments → Environment Variables**
3. **Add variables like `INSTAGRAM_APP_ID`**

## Security Best Practices

### **✅ Do:**
- Use build configurations for sensitive data
- Store secrets in Info.plist for app-specific values
- Validate credentials on app startup
- Use different credentials for Debug/Release builds
- Remove fallback values before App Store submission

### **❌ Don't:**
- Hardcode credentials in source code
- Commit sensitive data to version control
- Use production credentials in development
- Share credentials in plaintext

## Current Status

### **✅ Secured:**
- Instagram API credentials moved to Configuration.swift
- Backend URLs centralized in Configuration.swift
- Validation system in place

### **⚠️ Still Using Fallbacks:**
- Instagram credentials still have fallback values
- These need to be removed before production release

### **🔲 TODO:**
- Move Instagram credentials to Info.plist or build settings
- Remove fallback values from Configuration.swift
- Add keychain storage for sensitive long-term data
- Implement credential rotation system

## Validation

The app automatically validates credentials on startup and logs warnings:

```
⚠️ Instagram Service Configuration Warnings:
  - Instagram App Secret is using fallback value - move to secure storage
  - Instagram App ID is using fallback value - move to build configuration
```

## Migration Steps

### **For Production Release:**

1. **Add credentials to Info.plist:**
```xml
<key>INSTAGRAM_APP_ID</key>
<string>1041465901389740</string>
<key>INSTAGRAM_APP_SECRET</key>
<string>07b347bceebb140e2e75bd8c2f187c78</string>
<key>INSTAGRAM_USER_ID</key>
<string>17841400370020314</string>
<key>INSTAGRAM_MEDIA_ID</key>
<string>17843725936046658</string>
```

2. **Remove fallback values from Configuration.swift:**
```swift
var instagramAppId: String {
    return Bundle.main.object(forInfoDictionaryKey: "INSTAGRAM_APP_ID") as? String 
        ?? ProcessInfo.processInfo.environment["INSTAGRAM_APP_ID"] 
        ?? fatalError("INSTAGRAM_APP_ID not configured")
}
```

3. **Test that validation passes:**
```swift
let warnings = Configuration.shared.validateCredentials()
assert(warnings.isEmpty, "Credentials validation failed: \(warnings)")
```

## Testing

### **Development Testing:**
- Set environment variables in Xcode scheme
- Use test credentials for development
- Validate that configuration loading works

### **Production Testing:**
- Test with Info.plist credentials
- Ensure no warnings during startup
- Verify API calls work with configured credentials

## Security Incidents

If credentials are compromised:

1. **Immediately rotate Instagram tokens**
2. **Update Info.plist with new credentials**
3. **Release new app version**
4. **Monitor for unauthorized usage**

---

**Last Updated**: January 2025  
**Next Review**: Before App Store submission