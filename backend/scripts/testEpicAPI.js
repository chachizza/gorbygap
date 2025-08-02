#!/usr/bin/env node

/**
 * Epic API Test - Whistler Blackcomb Lift Status
 * Tests the discovered Epic API endpoint for real-time lift data
 * Endpoint: https://mtnapi-prod.azure-api.net/resortstatus/api/v1/resort/rpos/80/status
 */

const axios = require('axios');

class EpicAPITester {
    constructor() {
        this.baseURL = 'https://mtnapi-prod.azure-api.net';
        this.endpoint = '/resortstatus/api/v1/resort/rpos/80/status';
        this.fullURL = this.baseURL + this.endpoint;
    }

    async testEpicAPI() {
        console.log('🎿 EPIC API TEST - Whistler Blackcomb Lift Status');
        console.log('=' .repeat(60));
        console.log(`📡 Testing endpoint: ${this.fullURL}`);
        console.log('');

        try {
            // Test with various headers that might be required
            const headers = {
                'User-Agent': 'Gorby-App/1.0 (iOS; Mountain Data)',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Accept-Encoding': 'gzip, deflate',
                'Connection': 'keep-alive'
            };

            console.log('🔍 Making request with headers:');
            console.log(JSON.stringify(headers, null, 2));
            console.log('');

            const response = await axios.get(this.fullURL, {
                headers: headers,
                timeout: 10000,
                validateStatus: function (status) {
                    return status < 500; // Accept anything under 500 as we want to see what we get
                }
            });

            console.log('✅ SUCCESS! Got response from Epic API');
            console.log(`📊 Status Code: ${response.status} ${response.statusText}`);
            console.log(`📏 Response Size: ${JSON.stringify(response.data).length} characters`);
            console.log('');

            // Analyze response headers
            console.log('📋 Response Headers:');
            Object.keys(response.headers).forEach(key => {
                console.log(`   ${key}: ${response.headers[key]}`);
            });
            console.log('');

            // Analyze response data structure
            console.log('🔍 RESPONSE DATA ANALYSIS:');
            console.log('=' .repeat(40));
            
            if (response.data) {
                this.analyzeDataStructure(response.data);
                console.log('');
                this.mapToLiftData(response.data);
            } else {
                console.log('❌ No data in response');
            }

        } catch (error) {
            console.log('❌ ERROR occurred:');
            
            if (error.response) {
                // Server responded with error status
                console.log(`📊 Status Code: ${error.response.status} ${error.response.statusText}`);
                console.log(`📏 Error Response Size: ${JSON.stringify(error.response.data).length} characters`);
                console.log('');
                
                console.log('📋 Error Response Headers:');
                Object.keys(error.response.headers).forEach(key => {
                    console.log(`   ${key}: ${error.response.headers[key]}`);
                });
                console.log('');

                console.log('📄 Error Response Data:');
                console.log(JSON.stringify(error.response.data, null, 2));
                
                if (error.response.status === 401) {
                    console.log('');
                    console.log('🔐 AUTHENTICATION REQUIRED');
                    console.log('The API requires authentication. This is common for Epic APIs.');
                    console.log('We may need to:');
                    console.log('1. Register for an API key');
                    console.log('2. Use OAuth authentication');
                    console.log('3. Find alternative endpoints');
                }
            } else if (error.request) {
                console.log('📡 No response received from server');
                console.log('This could mean:');
                console.log('1. Network connectivity issues');
                console.log('2. Server is down');
                console.log('3. Endpoint does not exist');
            } else {
                console.log('⚠️ Request setup error:', error.message);
            }
            
            console.log('');
            console.log('🔧 Full error details:');
            console.log(error.message);
        }
    }

    analyzeDataStructure(data) {
        console.log('📊 Data Type:', typeof data);
        
        if (Array.isArray(data)) {
            console.log(`📋 Array with ${data.length} items`);
            if (data.length > 0) {
                console.log('🔍 First item structure:');
                console.log(JSON.stringify(data[0], null, 2));
            }
        } else if (typeof data === 'object' && data !== null) {
            console.log('🏗️ Object structure:');
            console.log('📋 Top-level keys:', Object.keys(data));
            
            // Look for lift-related data
            const liftKeys = Object.keys(data).filter(key => 
                key.toLowerCase().includes('lift') || 
                key.toLowerCase().includes('trail') ||
                key.toLowerCase().includes('status') ||
                key.toLowerCase().includes('open') ||
                key.toLowerCase().includes('closed')
            );
            
            if (liftKeys.length > 0) {
                console.log('🎿 Potential lift-related keys:', liftKeys);
                
                liftKeys.forEach(key => {
                    console.log(`\n🔍 Examining ${key}:`);
                    const value = data[key];
                    if (Array.isArray(value)) {
                        console.log(`   Array with ${value.length} items`);
                        if (value.length > 0) {
                            console.log('   Sample item:', JSON.stringify(value[0], null, 4));
                        }
                    } else {
                        console.log('   Value:', JSON.stringify(value, null, 4));
                    }
                });
            }
            
            console.log('');
            console.log('📄 Full response:');
            console.log(JSON.stringify(data, null, 2));
        } else {
            console.log('📄 Raw data:', data);
        }
    }

    mapToLiftData(data) {
        console.log('🗺️ MAPPING TO GORBY LIFT DATA FORMAT:');
        console.log('=' .repeat(40));
        
        console.log('Target LiftData structure:');
        const targetStructure = {
            id: "UUID",
            name: "String (lift name)",
            status: "String (Open/Closed/Delayed)",
            mountain: "String (Whistler/Blackcomb)",
            type: "String (lift type)",
            waitTime: "Int (minutes)",
            lastUpdated: "Date"
        };
        
        console.log(JSON.stringify(targetStructure, null, 2));
        console.log('');
        
        // Try to find lift data in the response
        let lifts = [];
        
        if (Array.isArray(data)) {
            lifts = data;
        } else if (data && typeof data === 'object') {
            // Look for arrays that might contain lift data
            Object.keys(data).forEach(key => {
                if (Array.isArray(data[key])) {
                    console.log(`🔍 Found array at key "${key}" with ${data[key].length} items`);
                    if (data[key].length > 0) {
                        console.log('Sample item:', JSON.stringify(data[key][0], null, 2));
                        
                        // Check if this looks like lift data
                        const sample = data[key][0];
                        if (sample && typeof sample === 'object') {
                            const keys = Object.keys(sample);
                            const liftLikeKeys = keys.filter(k => 
                                k.toLowerCase().includes('name') ||
                                k.toLowerCase().includes('status') ||
                                k.toLowerCase().includes('open') ||
                                k.toLowerCase().includes('id')
                            );
                            
                            if (liftLikeKeys.length > 0) {
                                console.log(`🎿 This looks like lift data! Keys: ${liftLikeKeys.join(', ')}`);
                                lifts = data[key];
                            }
                        }
                    }
                }
            });
        }
        
        if (lifts.length > 0) {
            console.log(`\n🎉 FOUND ${lifts.length} POTENTIAL LIFT RECORDS!`);
            console.log('');
            console.log('🔄 Attempting to map to Gorby format:');
            
            lifts.slice(0, 3).forEach((lift, index) => {
                console.log(`\n--- Lift ${index + 1} ---`);
                console.log('Raw data:', JSON.stringify(lift, null, 2));
                
                const mapped = this.mapSingleLift(lift);
                if (mapped) {
                    console.log('Mapped to Gorby format:');
                    console.log(JSON.stringify(mapped, null, 2));
                }
            });
            
        } else {
            console.log('❌ No lift data arrays found in response');
            console.log('This endpoint might not contain individual lift status');
        }
    }

    mapSingleLift(liftData) {
        if (!liftData || typeof liftData !== 'object') {
            return null;
        }
        
        // Try to extract common fields
        const keys = Object.keys(liftData);
        
        const nameKeys = keys.filter(k => k.toLowerCase().includes('name'));
        const statusKeys = keys.filter(k => k.toLowerCase().includes('status') || k.toLowerCase().includes('open'));
        const idKeys = keys.filter(k => k.toLowerCase().includes('id'));
        
        const mapped = {
            id: null,
            name: null,
            status: null,
            mountain: "Unknown",
            type: "Unknown", 
            waitTime: 0,
            lastUpdated: new Date().toISOString()
        };
        
        // Extract ID
        if (idKeys.length > 0) {
            mapped.id = liftData[idKeys[0]];
        }
        
        // Extract name
        if (nameKeys.length > 0) {
            mapped.name = liftData[nameKeys[0]];
        }
        
        // Extract status
        if (statusKeys.length > 0) {
            const status = liftData[statusKeys[0]];
            mapped.status = typeof status === 'boolean' ? (status ? 'Open' : 'Closed') : status;
        }
        
        // Try to determine mountain (Whistler vs Blackcomb)
        if (mapped.name) {
            const name = mapped.name.toLowerCase();
            if (name.includes('whistler') || name.includes('village') || name.includes('creekside')) {
                mapped.mountain = "Whistler";
            } else if (name.includes('blackcomb') || name.includes('upper') || name.includes('glacier')) {
                mapped.mountain = "Blackcomb";
            }
        }
        
        return mapped;
    }

    async testAlternativeEndpoints() {
        console.log('\n🔍 TESTING ALTERNATIVE EPIC ENDPOINTS:');
        console.log('=' .repeat(50));
        
        const alternatives = [
            '/resortstatus/api/v1/resort/rpos/80',
            '/resortstatus/api/v1/resort/80/status',
            '/resortstatus/api/v1/resort/80',
            '/api/v1/resort/rpos/80/status',
            '/api/v1/resort/rpos/80/lifts',
            '/resortstatus/api/v1/resort/rpos/80/lifts'
        ];
        
        for (const endpoint of alternatives) {
            const url = this.baseURL + endpoint;
            console.log(`\n📡 Testing: ${url}`);
            
            try {
                const response = await axios.get(url, {
                    timeout: 5000,
                    validateStatus: () => true
                });
                
                console.log(`   ✅ ${response.status} - Got response (${JSON.stringify(response.data).length} chars)`);
                
                if (response.status === 200 && response.data) {
                    console.log('   🎉 This endpoint returned data!');
                }
                
            } catch (error) {
                console.log(`   ❌ Failed: ${error.message.split('\n')[0]}`);
            }
        }
    }
}

// Run the test
async function main() {
    const tester = new EpicAPITester();
    await tester.testEpicAPI();
    await tester.testAlternativeEndpoints();
    
    console.log('\n' + '='.repeat(60));
    console.log('🎿 EPIC API TEST COMPLETE');
    console.log('🔄 Next steps based on results:');
    console.log('1. ✅ If data found: Integrate into backend');
    console.log('2. 🔐 If auth required: Research API key registration');
    console.log('3. ❌ If no data: Try alternative Epic endpoints');
    console.log('4. 🔍 If endpoint invalid: Research Epic API documentation');
    console.log('='.repeat(60));
}

main().catch(console.error);