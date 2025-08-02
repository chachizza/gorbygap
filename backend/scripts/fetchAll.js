#!/usr/bin/env node

/**
 * Gorby Backend - Fetch All Data Script
 * Runs lift status API
 * Follows .cursorrules: No mock data, live data only
 */

const DirectLiftAPI = require('./fetchLiftsDirect');

class DataFetcher {
    constructor() {
        this.liftAPI = new DirectLiftAPI();
    }

    log(message, level = 'info') {
        const timestamp = new Date().toISOString();
        console.log(`[${timestamp}] ${level.toUpperCase()}: ${message}`);
    }

    async fetchAll() {
        try {
            this.log('=== Starting Gorby Data Fetch (Lift Status) ===');
            
            const results = {
                lifts: null,
                errors: []
            };

            // Fetch lift status
            try {
                this.log('Fetching lift status data...');
                results.lifts = await this.liftAPI.run();
                this.log(`Successfully fetched ${results.lifts.liftCount} lifts`);
            } catch (error) {
                this.log(`Lift API failed: ${error.message}`, 'error');
                results.errors.push({ source: 'lifts', error: error.message });
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