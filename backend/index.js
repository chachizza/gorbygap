/**
 * Gorby Backend API Server
 * Express server providing live lift status and webcam data
 * Follows .cursorrules: No mock data, live data only, proper error handling
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cron = require('node-cron');
const fs = require('fs-extra');
const path = require('path');
require('dotenv').config();

const LiftStatusScraper = require('./scripts/fetchLifts');
const WebcamScraper = require('./scripts/fetchWebcams');
const DataFetcher = require('./scripts/fetchAll');

class GorbyAPI {
    constructor() {
        this.app = express();
        this.port = process.env.PORT || 3001;
        this.host = process.env.HOST || 'localhost';
        this.dataDir = path.join(__dirname, 'data');
        
        this.setupMiddleware();
        this.setupRoutes();
        this.setupCronJobs();
    }

    setupMiddleware() {
        // Security and logging
        this.app.use(helmet());
        this.app.use(cors());
        this.app.use(morgan('combined'));
        this.app.use(express.json());
    }

    setupRoutes() {
        // Health check
        this.app.get('/health', (req, res) => {
            res.json({
                status: 'ok',
                timestamp: new Date().toISOString(),
                service: 'Gorby Backend API',
                version: '1.0.0'
            });
        });

        // Live lift status endpoint
        this.app.get('/api/lifts', async (req, res) => {
            try {
                const filePath = path.join(this.dataDir, 'lifts.json');
                
                if (!await fs.pathExists(filePath)) {
                    // If no cached data, fetch fresh data
                    const scraper = new LiftStatusScraper();
                    const data = await scraper.run();
                    return res.json(data);
                }

                const data = await fs.readJson(filePath);
                const cacheAge = Date.now() - new Date(data.lastUpdated).getTime();
                const maxAge = parseInt(process.env.CACHE_DURATION_MINUTES) * 60 * 1000 || 600000; // 10 minutes default

                // If data is stale, refresh in background
                if (cacheAge > maxAge) {
                    // Don't await - refresh in background
                    this.refreshLiftData();
                }

                res.json(data);
            } catch (error) {
                console.error('Lift API error:', error);
                res.status(500).json({
                    error: 'Failed to fetch lift data',
                    message: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        });

        // Live webcam endpoint
        this.app.get('/api/webcams', async (req, res) => {
            try {
                const filePath = path.join(this.dataDir, 'webcams.json');
                
                if (!await fs.pathExists(filePath)) {
                    // If no cached data, fetch fresh data
                    const scraper = new WebcamScraper();
                    const data = await scraper.run();
                    return res.json(data);
                }

                const data = await fs.readJson(filePath);
                const cacheAge = Date.now() - new Date(data.lastUpdated).getTime();
                const maxAge = parseInt(process.env.CACHE_DURATION_MINUTES) * 60 * 1000 || 600000; // 10 minutes default

                // If data is stale, refresh in background
                if (cacheAge > maxAge) {
                    // Don't await - refresh in background
                    this.refreshWebcamData();
                }

                res.json(data);
            } catch (error) {
                console.error('Webcam API error:', error);
                res.status(500).json({
                    error: 'Failed to fetch webcam data',
                    message: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        });

        // Manual refresh endpoints
        this.app.post('/api/lifts/refresh', async (req, res) => {
            try {
                const scraper = new LiftStatusScraper();
                const data = await scraper.run();
                res.json({ success: true, data });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to refresh lift data',
                    message: error.message
                });
            }
        });

        this.app.post('/api/webcams/refresh', async (req, res) => {
            try {
                const scraper = new WebcamScraper();
                const data = await scraper.run();
                res.json({ success: true, data });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to refresh webcam data',
                    message: error.message
                });
            }
        });

        // Combined data endpoint
        this.app.get('/api/all', async (req, res) => {
            try {
                const [lifts, webcams] = await Promise.all([
                    this.loadDataFile('lifts.json'),
                    this.loadDataFile('webcams.json')
                ]);

                res.json({
                    lastUpdated: new Date().toISOString(),
                    lifts: lifts || { lifts: [], liftCount: 0 },
                    webcams: webcams || { webcams: [], webcamCount: 0 }
                });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to fetch combined data',
                    message: error.message
                });
            }
        });

        // 404 handler
        this.app.use('*', (req, res) => {
            res.status(404).json({
                error: 'Endpoint not found',
                path: req.originalUrl,
                availableEndpoints: [
                    'GET /health',
                    'GET /api/lifts',
                    'GET /api/webcams',
                    'GET /api/all',
                    'POST /api/lifts/refresh',
                    'POST /api/webcams/refresh'
                ]
            });
        });
    }

    async loadDataFile(filename) {
        const filePath = path.join(this.dataDir, filename);
        if (await fs.pathExists(filePath)) {
            return await fs.readJson(filePath);
        }
        return null;
    }

    async refreshLiftData() {
        try {
            console.log('Background refresh: lift data');
            const scraper = new LiftStatusScraper();
            await scraper.run();
        } catch (error) {
            console.error('Background lift refresh failed:', error.message);
        }
    }

    async refreshWebcamData() {
        try {
            console.log('Background refresh: webcam data');
            const scraper = new WebcamScraper();
            await scraper.run();
        } catch (error) {
            console.error('Background webcam refresh failed:', error.message);
        }
    }

    setupCronJobs() {
        // Refresh data every 7 minutes as requested
        cron.schedule('*/7 * * * *', async () => {
            console.log('Scheduled data refresh starting...');
            try {
                const fetcher = new DataFetcher();
                await fetcher.fetchAll();
                console.log('Scheduled data refresh completed');
            } catch (error) {
                console.error('Scheduled refresh failed:', error.message);
            }
        });

        console.log('Cron job scheduled: data refresh every 7 minutes');
    }

    async start() {
        try {
            // Ensure data directory exists
            await fs.ensureDir(this.dataDir);
            
            // Initial data fetch on startup
            console.log('Performing initial data fetch...');
            try {
                const fetcher = new DataFetcher();
                await fetcher.fetchAll();
                console.log('Initial data fetch completed');
            } catch (error) {
                console.warn('Initial data fetch failed, server will start anyway:', error.message);
            }

            this.app.listen(this.port, this.host, () => {
                console.log(`🚀 Gorby API Server running on http://${this.host}:${this.port}`);
                console.log('📡 Live data endpoints:');
                console.log(`   GET  http://${this.host}:${this.port}/api/lifts`);
                console.log(`   GET  http://${this.host}:${this.port}/api/webcams`);
                console.log(`   GET  http://${this.host}:${this.port}/api/all`);
                console.log('🔄 Auto-refresh: every 7 minutes');
            });

        } catch (error) {
            console.error('Failed to start server:', error);
            process.exit(1);
        }
    }
}

// Start server if called directly
if (require.main === module) {
    const api = new GorbyAPI();
    api.start();
}

module.exports = GorbyAPI; 