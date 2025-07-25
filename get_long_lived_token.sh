#!/bin/bash

echo "🔄 Instagram 60-Day Token Generator"
echo "=================================="

# STEP 1: Replace these with your actual values from Facebook Developer Console
APP_ID="YOUR_APP_ID"
APP_SECRET="YOUR_APP_SECRET" 
SHORT_LIVED_TOKEN="YOUR_SHORT_LIVED_TOKEN_FROM_GRAPH_EXPLORER"

echo "📋 Using App ID: ${APP_ID}"
echo "🔑 Exchanging token for 60-day version..."

# Exchange short-lived token for long-lived token (60 days)
response=$(curl -s "https://graph.facebook.com/v19.0/oauth/access_token?grant_type=fb_exchange_token&client_id=${APP_ID}&client_secret=${APP_SECRET}&fb_exchange_token=${SHORT_LIVED_TOKEN}")

echo ""
echo "📥 API Response:"
echo "$response"

# Check if we got an access_token in the response
if echo "$response" | grep -q "access_token"; then
    echo ""
    echo "✅ SUCCESS! Your 60-day token is ready!"
    echo ""
    echo "🎯 Next steps:"
    echo "1. Copy the 'access_token' value from above"
    echo "2. Update InstagramService.swift with your credentials"
    echo "3. Initialize the token in your app"
    echo ""
    echo "📅 This token will be valid for 60 days and auto-refresh!"
else
    echo ""
    echo "❌ ERROR: Failed to get long-lived token"
    echo "🔍 Check that you:"
    echo "   - Replaced APP_ID with your actual App ID"
    echo "   - Replaced APP_SECRET with your actual App Secret"  
    echo "   - Used a fresh token from Graph API Explorer"
    echo "   - The short-lived token hasn't expired (1 hour limit)"
fi

echo ""
echo "🆘 Need help? Check the troubleshooting section in instagram_token_guide.md"
