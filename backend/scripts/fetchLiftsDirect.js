#!/usr/bin/env node

/**
 * Gorby Backend - Real-Time Lift Status API
 * Fetches individual lift status from Vail Resorts Maps API
 * Based on Charles Proxy discovery: /resorts/19/maps endpoint
 * Follows .cursorrules: No mock data, live data only, proper error handling
 */

const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');

class DirectLiftAPI {
    constructor() {
        // Discovered working endpoint from Charles Proxy
        this.mapsEndpoint = 'https://api-az.vailresorts.com/digital/uiservice/api/v1/resorts/19/maps';
        this.resortId = '19'; // Whistler Blackcomb
        this.dataDir = path.join(__dirname, '../data');
        this.logFile = path.join(__dirname, '../data/lifts-realtime-log.json');
        
        // Authentication headers captured from Charles Proxy
        this.authHeaders = {
            'User-Agent': 'ApolloMobile/14 CFNetwork/3826.500.131 Darwin/24.5.0',
            'client_id': 'acd8be1a83f441dbb9dfa5a598a1f6d2',
            'client_secret': 'DDC5a7ccC7534c909bE5e1726ed0B8bf',
            'accept': 'application/json, text/plain, */*',
            'accept-encoding': 'gzip, deflate, br',
            'accept-language': 'en-CA,en-US;q=0.9,en;q=0.8',
            'connection': 'keep-alive',
            'cache-control': 'no-cache',
            'pragma': 'no-cache'
        };
    }

    async fetchLiftData() {
        try {
            console.log('🎿 Fetching REAL-TIME lift data from Vail Maps API...');
            console.log(`📡 Endpoint: ${this.mapsEndpoint}`);
            
            const response = await axios.get(this.mapsEndpoint, {
                headers: this.authHeaders,
                timeout: 15000,
                validateStatus: function (status) {
                    return status >= 200 && status < 500;
                }
            });

            if (response.status !== 200) {
                throw new Error(`API returned ${response.status}: ${response.statusText}`);
            }

            console.log('✅ Real-time Maps API data fetched successfully');
            console.log(`📏 Response size: ${JSON.stringify(response.data).length} characters`);

            // Parse the real lift data
            const liftData = this.parseRealLiftData(response.data);
            
            // Save to file
            await this.saveData(liftData);
            
            console.log(`✅ Successfully processed ${liftData.liftCount} real lifts from Maps API`);
            this.log('SUCCESS', `Fetched ${liftData.liftCount} real lifts from Maps API`);
            
            return liftData;

        } catch (error) {
            console.error('❌ Error fetching real-time lift data:', error.message);
            
            if (error.response) {
                console.error(`   Status: ${error.response.status} ${error.response.statusText}`);
                if (error.response.status === 401) {
                    console.error('   🔐 Authentication failed - API credentials may have expired');
                } else if (error.response.status === 403) {
                    console.error('   🚫 Forbidden - API access denied');
                }
            }
            
            this.log('ERROR', `${error.message} (Status: ${error.response?.status || 'N/A'})`);
            
            // Return error state - no fallback data per .cursorrules
            return {
                lastUpdated: new Date().toISOString(),
                source: 'api-error',
                liftCount: 0,
                lifts: [],
                error: `Live lift data unavailable: ${error.message}`
            };
        }
    }

    parseRealLiftData(mapsData) {
        console.log('🗺️ Parsing real lift data from Maps API...');
        
        const lifts = [];
        const seenLifts = new Set(); // Track lift names to avoid duplicates

        // The Maps API returns an array of map objects, each containing lifts
        mapsData.forEach((map, mapIndex) => {
            console.log(`📍 Processing map ${mapIndex + 1}: ${map.mapName}`);
            
            if (map.lifts && Array.isArray(map.lifts)) {
                console.log(`  🎿 Found ${map.lifts.length} lifts in this map`);
                
                map.lifts.forEach((lift, liftIndex) => {
                    const liftData = lift.data;
                    
                    if (!liftData.name) {
                        return;
                    }

                    // Check for duplicates using normalized lift name
                    const normalizedLiftName = liftData.name.trim().toLowerCase();
                    if (seenLifts.has(normalizedLiftName)) {
                        console.log(`    ⚠️ Skipping duplicate lift: ${liftData.name}`);
                        return;
                    }
                    
                    seenLifts.add(normalizedLiftName);

                    const mappedLift = {
                        liftName: liftData.name,
                        status: this.mapLiftStatus(liftData.openingStatus),
                        mountain: this.determineMountain(liftData.name, liftData.sector, map.mapName),
                        type: this.mapLiftType(liftData.liftType),
                        waitTime: this.extractWaitTime(liftData),
                        capacity: liftData.capacity || 0,
                        lastUpdated: new Date().toISOString()
                    };

                    lifts.push(mappedLift);
                    
                    // Log first few lifts for debugging
                    if (liftIndex < 2 && lifts.length <= 5) {
                        console.log(`    Lift ${lifts.length}: ${mappedLift.liftName} - ${mappedLift.status} (${mappedLift.mountain})`);
                    }
                });
            }
        });

        // Calculate statistics
        const openLifts = lifts.filter(lift => lift.status === 'Open');
        const closedLifts = lifts.filter(lift => lift.status === 'Closed');
        
        console.log(`📈 Lift Status Summary:`);
        console.log(`   ✅ Open: ${openLifts.length}`);
        console.log(`   ❌ Closed: ${closedLifts.length}`);
        console.log(`   📊 Total: ${lifts.length}`);

        return {
            lastUpdated: new Date().toISOString(),
            source: 'live-data',
            liftCount: lifts.length,
            lifts: lifts,
            summary: {
                open: openLifts.length,
                closed: closedLifts.length,
                total: lifts.length
            }
        };
    }

    mapLiftStatus(openingStatus) {
        if (!openingStatus) return 'Unknown';
        
        switch (openingStatus.toUpperCase()) {
            case 'OPEN':
                return 'Open';
            case 'CLOSED':
                return 'Closed';
            case 'DELAYED':
                return 'Delayed';
            case 'HOLD':
                return 'On Hold';
            default:
                return openingStatus;
        }
    }

    mapLiftType(liftType) {
        if (!liftType) return 'Unknown';
        
        const typeMap = {
            'GONDOLA': 'Gondola',
            'DETACHABLE_CHAIRLIFT': 'Express Chair',
            'CHAIRLIFT': 'Fixed Chair',
            'SURFACE_LIFT': 'Surface Lift',
            'T_BAR': 'T-Bar',
            'FUNICULAR': 'Funicular'
        };

        return typeMap[liftType.toUpperCase()] || liftType;
    }

    determineMountain(liftName, sector, mapName) {
        if (!liftName && !sector && !mapName) return 'Unknown';
        
        const nameText = (liftName || '').toLowerCase();
        const sectorText = (sector || '').toLowerCase();
        const mapText = (mapName || '').toLowerCase();
        
        // Peak 2 Peak connects both mountains
        if (nameText.includes('peak 2 peak') || nameText.includes('peak to peak')) {
            return 'Both';
        }
        
        // Blackcomb Mountain indicators (check these first for specificity)
        if (nameText.includes('blackcomb') || 
            sectorText.includes('blackcomb') ||
            mapText.includes('blackcomb') ||
            mapText.includes('7th heaven') || 
            nameText.includes('7th heaven') ||
            nameText.includes('glacier express') ||
            nameText.includes('catskinner') ||
            nameText.includes('jersey cream') ||
            nameText.includes('showcase t-bar') ||
            nameText.includes('horstman') ||
            nameText.includes('excelerator') ||
            nameText.includes('crystal ridge') ||
            nameText.includes('fitzsimmons')) {
            return 'Blackcomb';
        }
        
        // Whistler Mountain indicators
        if (nameText.includes('whistler') || 
            sectorText.includes('whistler') ||
            nameText.includes('village gondola') ||
            nameText.includes('creekside') ||
            nameText.includes('peak express') ||
            nameText.includes('harmony') ||
            nameText.includes('emerald') ||
            nameText.includes('garbanzo') ||
            nameText.includes('olympic') ||
            nameText.includes('symphony') ||
            nameText.includes('franz') ||
            nameText.includes('big red') ||
            nameText.includes('red chair') ||
            nameText.includes('orange chair') ||
            nameText.includes('magic chair') ||
            nameText.includes('tube park')) {
            return 'Whistler';
        }
        
        // Fallback: use map-based classification for edge cases
        if (mapText.includes('main map') || mapText.includes('symphony')) {
            return 'Whistler';
        }
        
        return 'Unknown';
    }

    extractWaitTime(liftData) {
        if (liftData.waitTime && liftData.waitTime > 0) {
            return liftData.waitTime;
        }
        
        if (liftData.waitTimeStatus === 'DISABLED' || liftData.openingStatus === 'CLOSED') {
            return null;
        }

        return null;
    }

    async saveData(data) {
        await fs.ensureDir(this.dataDir);
        await fs.writeJson(path.join(this.dataDir, 'lifts.json'), data, { spaces: 2 });
    }

    log(status, message) {
        this.appendToLogFile({
            timestamp: new Date().toISOString(),
            status,
            message,
            endpoint: this.mapsEndpoint
        });
    }

    // Backward compatibility method for existing backend
    async run() {
        return await this.fetchLiftData();
    }

    async appendToLogFile(logEntry) {
        try {
            await fs.ensureDir(this.dataDir);
            
            let logs = [];
            if (await fs.pathExists(this.logFile)) {
                try {
                    logs = await fs.readJson(this.logFile);
                } catch (error) {
                    console.error('Error reading log file:', error.message);
                }
            }
            
            logs.push(logEntry);
            
            // Keep only last 100 entries
            if (logs.length > 100) {
                logs = logs.slice(-100);
            }
            
            await fs.writeJson(this.logFile, logs, { spaces: 2 });
        } catch (error) {
            console.error('Failed to write to log file:', error.message);
        }
    }
}

// Run if called directly
if (require.main === module) {
    const api = new DirectLiftAPI();
    api.fetchLiftData()
        .then(data => {
            console.log('✅ Lift data fetch completed');
            process.exit(0);
        })
        .catch(error => {
            console.error('❌ Lift data fetch failed:', error.message);
            process.exit(1);
        });
}

module.exports = DirectLiftAPI; 