// Initialize Instagram Token
// Add this code to your app's startup (GorbyApp.swift or first view)

let instagramService = InstagramService()

// Initialize with your 60-day token (expires_in: 5184000 = 60 days)
instagramService.initializeToken(
    "EAAOzNS0ZAF6wBPCE7ILXFiBItXRezOkGPcLEoG8ZBTdoS2StqZB1nsMdRXqrHjwsSJqXdbVpgbkNmyKt7sIsZBUiyDSN97GRe5mzyZCN4jeK6WZBacxIC2OUKLWpBk37wHOpcf2ZCvw4aYLQDi4SZBqyfXjzAaaawiO3hZABiz6Tzboo4of7Kv0Se2364MygCTsWL97gUxVLObXJT", 
    expiresIn: 5184000
)
