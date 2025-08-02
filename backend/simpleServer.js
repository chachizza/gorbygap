const express = require('express');
const fs = require('fs-extra');
const path = require('path');
const DirectLiftAPI = require('./scripts/fetchLiftsDirect');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static('public'));

// CORS headers
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    if (req.method === 'OPTIONS') {
        res.sendStatus(200);
    } else {
        next();
    }
});

// Health check endpoint
app.get('/api/status', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: 'Gorby Lift Status API',
        version: '2.0.0'
    });
});

// Main lifts endpoint
app.get('/api/lifts', async (req, res) => {
    try {
        const dataPath = path.join(__dirname, 'data', 'lifts.json');
        
        if (await fs.pathExists(dataPath)) {
            const data = await fs.readJson(dataPath);
            if (data && data.lifts && data.lifts.length > 0) {
                res.json(data);
            } else {
                console.log('No lift data available - API not accessible');
                res.json({
                    lastUpdated: new Date().toISOString(),
                    source: 'no-data',
                    liftCount: 0,
                    lifts: [],
                    error: 'Live lift data temporarily unavailable'
                });
            }
        } else {
            console.log('No lift data file found - API not accessible');
            res.json({
                lastUpdated: new Date().toISOString(),
                source: 'no-data',
                liftCount: 0,
                lifts: [],
                error: 'Live lift data temporarily unavailable'
            });
        }
    } catch (error) {
        console.error('Error reading lift data:', error);
        res.status(500).json({
            error: 'Internal server error',
            message: error.message
        });
    }
});

// Manual refresh endpoint
app.get('/api/lifts/refresh', async (req, res) => {
    try {
        console.log('🔄 Manual lift data refresh requested');
        
        const api = new DirectLiftAPI();
        const data = await api.fetchLiftData();
        
        res.json({
            success: true,
            message: 'Lift data refreshed successfully',
            data: data
        });
    } catch (error) {
        console.error('❌ Manual refresh failed:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to refresh lift data',
            message: error.message
        });
    }
});

// Test live API endpoint
app.get('/api/test-live', async (req, res) => {
    try {
        console.log('Testing live API with cookies...');
        
        const axios = require('axios');
        const cookies = process.env.VAIL_COOKIES;
        
        if (!cookies) {
            return res.json({
                success: false,
                message: 'No cookies provided',
                error: 'VAIL_COOKIES environment variable not set'
            });
        }
        
        const headers = {
            'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
            'Accept': 'application/json, text/plain, */*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'Referer': 'https://www.epicpass.com/',
            'Origin': 'https://www.epicpass.com/',
            'Cookie': cookies
        };

        // Test both endpoints
        const summaryResponse = await axios.get('https://api-az.vailresorts.com/digital/uiservice/api/v1/resorts/19', {
            headers,
            timeout: 10000
        });
        
        const mapsResponse = await axios.get('https://api-az.vailresorts.com/digital/uiservice/api/v1/resorts/19/maps', {
            headers,
            timeout: 10000
        });
        
        console.log('Live API test successful!');
        res.json({
            success: true,
            message: 'Live API test successful',
            summary: summaryResponse.data,
            maps: mapsResponse.data
        });
    } catch (error) {
        console.error('Live API test failed:', error.message);
        res.json({
            success: false,
            message: 'Live API test failed',
            error: error.message,
            status: error.response?.status
        });
    }
});

// Combined data endpoint
app.get('/api/all', async (req, res) => {
    try {
        const dataPath = path.join(__dirname, 'data', 'lifts.json');
        
        if (await fs.pathExists(dataPath)) {
            const liftData = await fs.readJson(dataPath);
            res.json({
                lifts: liftData,
                timestamp: new Date().toISOString()
            });
        } else {
            res.json({
                lifts: {
                    lastUpdated: new Date().toISOString(),
                    source: 'no-data',
                    liftCount: 0,
                    lifts: [],
                    error: 'Live lift data temporarily unavailable'
                },
                timestamp: new Date().toISOString()
            });
        }
    } catch (error) {
        console.error('Error reading combined data:', error);
        res.status(500).json({
            error: 'Internal server error',
            message: error.message
        });
    }
});

// Data file endpoint
app.get('/api/data/:filename', async (req, res) => {
    try {
        const filename = req.params.filename;
        const filePath = path.join(__dirname, 'data', filename);
        
        if (await fs.pathExists(filePath)) {
            const data = await fs.readJson(filePath);
            res.json(data);
        } else {
            res.status(404).json({
                error: 'File not found',
                filename: filename
            });
        }
    } catch (error) {
        console.error('Error reading data file:', error);
        res.status(500).json({
            error: 'Internal server error',
            message: error.message
        });
    }
});

// Auto-refresh function
async function startAutoRefresh() {
    console.log('🔄 Starting automatic lift data refresh...');
    
    const api = new DirectLiftAPI();
    
    // Initial fetch
    try {
        await api.fetchLiftData();
        console.log('✅ Initial lift data fetch completed');
    } catch (error) {
        console.error('❌ Initial lift data fetch failed:', error.message);
    }
    
    // Refresh every 5 minutes
    setInterval(async () => {
        try {
            console.log('🔄 Auto-refreshing lift data...');
            await api.fetchLiftData();
            console.log('✅ Auto-refresh completed');
        } catch (error) {
            console.error('❌ Auto-refresh failed:', error.message);
        }
    }, 5 * 60 * 1000); // 5 minutes
}

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Gorby Lift Status API server running on port ${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/status`);
    console.log(`🎿 Lift data: http://localhost:${PORT}/api/lifts`);
    console.log(`🔄 Manual refresh: http://localhost:${PORT}/api/lifts/refresh`);
    console.log(`🧪 Test live API: http://localhost:${PORT}/api/test-live`);
    
    // Start auto-refresh
    startAutoRefresh();
});

module.exports = app; 