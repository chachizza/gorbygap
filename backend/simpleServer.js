const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Auto-refresh mechanism
let refreshInterval;

function startAutoRefresh() {
    console.log('🔄 Starting auto-refresh every 7 minutes using ChatGPT scraper');
    
    refreshInterval = setInterval(async () => {
        try {
            console.log('⚡ Auto-refresh triggered - running ChatGPT scraper');
            const LiftStatusScraper = require('./scripts/fetchLifts');
            const scraper = new LiftStatusScraper();
            await scraper.run();
            console.log('✅ Auto-refresh completed successfully');
        } catch (error) {
            console.error('❌ Auto-refresh failed:', error.message);
        }
    }, 7 * 60 * 1000); // 7 minutes
}

// Start auto-refresh when server starts
startAutoRefresh();

// Safe JSON file reader with retries
function readJsonFile(filePath, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            if (!fs.existsSync(filePath)) {
                return null;
            }
            
            const data = fs.readFileSync(filePath, 'utf8');
            
            // Check if file is empty or incomplete
            if (!data || data.trim().length === 0) {
                console.warn(`File ${filePath} is empty, attempt ${i + 1}`);
                if (i < maxRetries - 1) {
                    // Wait 100ms before retry
                    require('child_process').execSync('sleep 0.1');
                    continue;
                }
                return null;
            }
            
            return JSON.parse(data);
        } catch (error) {
            console.warn(`Error reading ${filePath}, attempt ${i + 1}:`, error.message);
            if (i < maxRetries - 1) {
                // Wait 100ms before retry
                require('child_process').execSync('sleep 0.1');
            }
        }
    }
    return null;
}

// Health check
app.get('/health', (req, res) => {
    console.log('Health check requested');
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: 'Gorby Simple API',
        autoRefresh: 'active'
    });
});

// Lifts endpoint
app.get('/api/lifts', (req, res) => {
    try {
        console.log('Lifts data requested');
        const liftsFile = path.join(__dirname, 'data', 'lifts.json');
        
        const data = readJsonFile(liftsFile);
        
        if (data) {
            res.json(data);
        } else {
            console.log('Using fallback lift data');
            res.json({
                lastUpdated: new Date().toISOString(),
                source: 'fallback',
                liftCount: 2,
                lifts: [
                    {
                        liftName: "Peak Express",
                        status: "Open",
                        mountain: "Whistler",
                        type: "Express Chair",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Blackcomb Gondola", 
                        status: "Open",
                        mountain: "Blackcomb",
                        type: "Gondola",
                        lastUpdated: new Date().toISOString()
                    }
                ]
            });
        }
    } catch (error) {
        console.error('Error serving lifts:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Webcams endpoint
app.get('/api/webcams', (req, res) => {
    try {
        console.log('Webcams data requested');
        const webcamsFile = path.join(__dirname, 'data', 'webcams.json');
        
        const data = readJsonFile(webcamsFile);
        
        if (data) {
            res.json(data);
        } else {
            console.log('Using fallback webcam data');
            res.json({
                lastUpdated: new Date().toISOString(),
                source: 'fallback',
                webcamCount: 2,
                webcams: [
                    {
                        name: "Peak Webcam",
                        location: "Whistler Peak",
                        url: "https://www.whistlerblackcomb.com/webcams/peak.jpg",
                        isLive: true,
                        lastUpdated: new Date().toISOString(),
                        elevation: 2180
                    },
                    {
                        name: "Village Webcam", 
                        location: "Whistler Village",
                        url: "https://www.whistlerblackcomb.com/webcams/village.jpg",
                        isLive: true,
                        lastUpdated: new Date().toISOString(),
                        elevation: 675
                    }
                ]
            });
        }
    } catch (error) {
        console.error('Error serving webcams:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Combined data endpoint
app.get('/api/all', (req, res) => {
    try {
        console.log('All data requested');
        const liftsFile = path.join(__dirname, 'data', 'lifts.json');
        const webcamsFile = path.join(__dirname, 'data', 'webcams.json');
        
        const liftsData = readJsonFile(liftsFile) || { lifts: [] };
        const webcamsData = readJsonFile(webcamsFile) || { webcams: [] };
        
        res.json({
            lastUpdated: new Date().toISOString(),
            lifts: liftsData.lifts || [],
            webcams: webcamsData.webcams || []
        });
    } catch (error) {
        console.error('Error serving combined data:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Manual refresh endpoint for lifts
app.post('/api/lifts/refresh', async (req, res) => {
    try {
        console.log('Manual lift refresh requested');
        
        const LiftStatusScraper = require('./scripts/fetchLifts');
        const scraper = new LiftStatusScraper();
        
        const result = await scraper.run();
        
        res.json({
            success: true,
            message: `Refreshed ${result.liftCount} lifts`,
            data: result
        });
    } catch (error) {
        console.error('Error refreshing lifts:', error);
        res.status(500).json({ error: 'Refresh failed', message: error.message });
    }
});

// Start server
app.listen(port, '0.0.0.0', () => {
    console.log(`🚀 Gorby API running on http://0.0.0.0:${port}`);
    console.log('Available endpoints:');
    console.log(`  GET http://localhost:${port}/health`);
    console.log(`  GET http://localhost:${port}/api/lifts`);
    console.log(`  GET http://localhost:${port}/api/webcams`);
    console.log(`  GET http://localhost:${port}/api/all`);
    console.log(`  POST http://localhost:${port}/api/lifts/refresh`);
    console.log('');
    console.log('🤖 ChatGPT/OpenAI Integration: ACTIVE');
    console.log('🔄 Auto-refresh: Every 7 minutes');
    console.log('📱 For iPhone testing, use your Mac IP address:');
    console.log(`  Find your Mac IP: ifconfig | grep "inet " | grep -v 127.0.0.1`);
});

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down gracefully...');
    if (refreshInterval) {
        clearInterval(refreshInterval);
        console.log('🔄 Auto-refresh stopped');
    }
    process.exit(0);
});

// Handle errors
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
}); 