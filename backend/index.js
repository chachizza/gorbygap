/**
 * Gorby Backend API Server
 * Express server providing live lift status data
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

const DirectLiftAPI = require('./scripts/fetchLiftsDirect');
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
                    const api = new DirectLiftAPI();
                    const data = await api.run();
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

        // Manual refresh endpoint for lifts
        this.app.post('/api/lifts/refresh', async (req, res) => {
            try {
                const api = new DirectLiftAPI();
                const data = await api.run();
                res.json({ success: true, data });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to refresh lift data',
                    message: error.message
                });
            }
        });

        // Combined data endpoint (lifts only)
        this.app.get('/api/all', async (req, res) => {
            try {
                const lifts = await this.loadDataFile('lifts.json');

                res.json({
                    lastUpdated: new Date().toISOString(),
                    lifts: lifts || { lifts: [], liftCount: 0 }
                });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to fetch combined data',
                    message: error.message,
                    timestamp: new Date().toISOString()
                });
            }
        });

        // Data files endpoint
        this.app.get('/api/data/:filename', async (req, res) => {
            try {
                const filename = req.params.filename;
                const filePath = path.join(this.dataDir, filename);
                
                if (!await fs.pathExists(filePath)) {
                    return res.status(404).json({
                        error: 'File not found',
                        filename: filename
                    });
                }
                
                const data = await fs.readJson(filePath);
                res.json(data);
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to read data file',
                    message: error.message
                });
            }
        });

        // Status endpoint
        this.app.get('/api/status', async (req, res) => {
            try {
                const liftsExists = await fs.pathExists(path.join(this.dataDir, 'lifts.json'));

                res.json({
                    status: 'operational',
                    timestamp: new Date().toISOString(),
                    services: {
                        lifts: liftsExists ? 'available' : 'unavailable'
                    },
                    lastUpdated: {
                        lifts: liftsExists ? await this.getLastUpdated('lifts.json') : null
                    }
                });
            } catch (error) {
                res.status(500).json({
                    error: 'Failed to get status',
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
                    'GET /api/all',
                    'GET /api/status',
                    'GET /api/data/:filename',
                    'POST /api/lifts/refresh'
                ]
            });
        });
    }

    async loadDataFile(filename) {
        try {
            const filePath = path.join(this.dataDir, filename);
            if (await fs.pathExists(filePath)) {
                return await fs.readJson(filePath);
            }
            return null;
        } catch (error) {
            console.error(`Error loading ${filename}:`, error);
            return null;
        }
    }

    async refreshLiftData() {
        try {
            console.log('🔄 Refreshing lift data in background...');
            const api = new DirectLiftAPI();
            await api.run();
            console.log('✅ Lift data refreshed successfully');
        } catch (error) {
            console.error('❌ Failed to refresh lift data:', error);
        }
    }

    async getLastUpdated(filename) {
        try {
            const filePath = path.join(this.dataDir, filename);
            if (await fs.pathExists(filePath)) {
                const data = await fs.readJson(filePath);
                return data.lastUpdated || null;
            }
            return null;
        } catch (error) {
            return null;
        }
    }

    setupCronJobs() {
        // Refresh lift data every 7 minutes
        cron.schedule('*/7 * * * *', async () => {
            console.log('🕐 Scheduled lift data refresh...');
            await this.refreshLiftData();
        });

        // Health check every 5 minutes
        cron.schedule('*/5 * * * *', () => {
            console.log('💚 Health check - server running normally');
        });
    }

    async start() {
        try {
            // Ensure data directory exists
            await fs.ensureDir(this.dataDir);
            
            // Start server
            this.app.listen(this.port, this.host, () => {
                console.log(`🚀 Gorby Backend API running on http://${this.host}:${this.port}`);
                console.log(` Health check: http://${this.host}:${this.port}/health`);
                console.log(`🎿 Lift status: http://${this.host}:${this.port}/api/lifts`);
                console.log(`📈 Status: http://${this.host}:${this.port}/api/status`);
            });
        } catch (error) {
            console.error('❌ Failed to start server:', error);
            process.exit(1);
        }
    }
}

// Start the server
const api = new GorbyAPI();
api.start().catch(console.error); 