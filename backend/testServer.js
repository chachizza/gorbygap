/**
 * Gorby Test API Server - No OpenAI Required
 * Simple server for testing Swift app integration
 */

const express = require('express');
const cors = require('cors');
const fs = require('fs-extra');
const path = require('path');

const app = express();
const port = 3001;
const dataDir = path.join(__dirname, 'data');

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        service: 'Gorby Test API',
        version: '1.0.0-test'
    });
});

// Test lift data endpoint
app.get('/api/lifts', async (req, res) => {
    try {
        const testFile = path.join(dataDir, 'test-lifts.json');
        
        if (await fs.pathExists(testFile)) {
            const data = await fs.readJson(testFile);
            res.json(data);
        } else {
            // Return fallback test data
            const fallbackData = {
                lastUpdated: new Date().toISOString(),
                source: 'test-fallback',
                liftCount: 3,
                lifts: [
                    {
                        liftName: "Peak Express",
                        status: "Open",
                        mountain: "Whistler",
                        type: "Express Chair",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Harmony 6",
                        status: "Closed",
                        mountain: "Whistler", 
                        type: "6-person Express",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Glacier Express",
                        status: "Open",
                        mountain: "Blackcomb",
                        type: "4-person Express", 
                        lastUpdated: new Date().toISOString()
                    }
                ]
            };
            res.json(fallbackData);
        }
    } catch (error) {
        res.status(500).json({
            error: 'Failed to fetch test lift data',
            message: error.message
        });
    }
});

// Test webcam data endpoint
app.get('/api/webcams', (req, res) => {
    const webcamData = {
        lastUpdated: new Date().toISOString(),
        source: 'test',
        webcamCount: 3,
        webcams: [
            {
                name: "Roundhouse Lodge",
                imageUrl: "https://images.unsplash.com/photo-1551524164-d0bb4b4e8bcb",
                location: "Whistler Mountain",
                isLive: true,
                lastUpdated: new Date().toISOString()
            },
            {
                name: "Peak Chair",
                imageUrl: "https://images.unsplash.com/photo-1551524164-0c2e3a8b7b4b",
                location: "Whistler Peak",
                isLive: true,
                lastUpdated: new Date().toISOString()
            },
            {
                name: "Glacier Lodge",
                imageUrl: "https://images.unsplash.com/photo-1551524164-0c2e3a8b7b4c",
                location: "Blackcomb Mountain",
                isLive: false,
                lastUpdated: new Date().toISOString()
            }
        ]
    };
    res.json(webcamData);
});

// Combined endpoint
app.get('/api/all', async (req, res) => {
    try {
        // Get lift data from the other endpoint
        const liftsResponse = await new Promise((resolve) => {
            const mockReq = {};
            const mockRes = {
                json: (data) => resolve(data)
            };
            app._router.handle(mockReq, mockRes);
        });

        res.json({
            lastUpdated: new Date().toISOString(),
            lifts: {
                liftCount: 3,
                lifts: [
                    {
                        liftName: "Peak Express",
                        status: "Open",
                        mountain: "Whistler",
                        type: "Express Chair",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Harmony 6", 
                        status: "Closed",
                        mountain: "Whistler",
                        type: "6-person Express",
                        lastUpdated: new Date().toISOString()
                    }
                ]
            },
            webcams: {
                webcamCount: 2,
                webcams: [
                    {
                        name: "Roundhouse Lodge",
                        imageUrl: "https://images.unsplash.com/photo-1551524164-d0bb4b4e8bcb",
                        location: "Whistler Mountain",
                        isLive: true,
                        lastUpdated: new Date().toISOString()
                    }
                ]
            }
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to fetch combined data',
            message: error.message
        });
    }
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        path: req.originalUrl,
        availableEndpoints: [
            'GET /health',
            'GET /api/lifts',
            'GET /api/webcams', 
            'GET /api/all'
        ]
    });
});

app.listen(port, () => {
    console.log(`🧪 Gorby Test API Server running on http://localhost:${port}`);
    console.log('📡 Test endpoints available:');
    console.log(`   GET  http://localhost:${port}/health`);
    console.log(`   GET  http://localhost:${port}/api/lifts`);
    console.log(`   GET  http://localhost:${port}/api/webcams`);
    console.log(`   GET  http://localhost:${port}/api/all`);
    console.log('💡 This serves test data while you set up OpenAI billing');
});

module.exports = app; 