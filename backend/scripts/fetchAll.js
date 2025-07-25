#!/usr/bin/env node

/**
 * Gorby Backend - Fetch All Data Script
 * Runs both lift status and webcam scrapers in sequence
 * Follows .cursorrules: No mock data, live data only
 */

const LiftStatusScraper = require('./fetchLifts');
const WebcamScraper = require('./fetchWebcams');

class DataFetcher {
    constructor() {
        this.liftScraper = new LiftStatusScraper();
        this.webcamScraper = new WebcamScraper();
    }

    log(message, level = 'info') {
        const timestamp = new Date().toISOString();
        console.log(`[${timestamp}] ${level.toUpperCase()}: ${message}`);
    }

    async fetchAll() {
        try {
            this.log('=== Starting Gorby Data Fetch (All Sources) ===');
            
            const results = {
                lifts: null,
                webcams: null,
                errors: []
            };

            // Fetch lift status
            try {
                this.log('Fetching lift status data...');
                results.lifts = await this.liftScraper.run();
                this.log(`Successfully fetched ${results.lifts.liftCount} lifts`);
            } catch (error) {
                this.log(`Lift scraping failed: ${error.message}`, 'error');
                results.errors.push({ source: 'lifts', error: error.message });
            }

            // Fetch webcam data
            try {
                this.log('Fetching webcam data...');
                results.webcams = await this.webcamScraper.run();
                this.log(`Successfully fetched ${results.webcams.webcamCount} webcams`);
            } catch (error) {
                this.log(`Webcam scraping failed: ${error.message}`, 'error');
                results.errors.push({ source: 'webcams', error: error.message });
            }

            this.log('=== Data fetch completed ===');
            
            if (results.errors.length > 0) {
                this.log(`Completed with ${results.errors.length} errors`, 'warn');
                results.errors.forEach(err => {
                    this.log(`  ${err.source}: ${err.error}`, 'warn');
                });
            }

            return results;

        } catch (error) {
            this.log(`Fatal error: ${error.message}`, 'error');
            process.exit(1);
        }
    }
}

// Run if called directly
if (require.main === module) {
    const fetcher = new DataFetcher();
    fetcher.fetchAll();
}

module.exports = DataFetcher; 