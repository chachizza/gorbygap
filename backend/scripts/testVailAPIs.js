#!/usr/bin/env node

/**
 * Vail Resorts API Discovery Test
 * Tests known and potential Vail Resorts API endpoints for lift status data
 */

const axios = require('axios');

class VailAPITester {
    constructor() {
        this.testResults = [];
    }

    async testAPI(url, description) {
        console.log(`\n📡 Testing: ${description}`);
        console.log(`   URL: ${url}`);
        
        try {
            const response = await axios.get(url, {
                headers: {
                    'User-Agent': 'Gorby-App/1.0 (iOS; Mountain Data)',
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                timeout: 10000,
                validateStatus: function (status) {
                    return status < 500; // Accept anything under 500
                }
            });

            const result = {
                url,
                description,
                status: response.status,
                statusText: response.statusText,
                dataSize: JSON.stringify(response.data).length,
                hasData: !!response.data,
                success: response.status === 200
            };

            console.log(`   ✅ ${response.status} ${response.statusText} - ${result.dataSize} chars`);
            
            if (response.status === 200 && response.data) {
                console.log(`   🎉 SUCCESS! Got ${result.dataSize} characters of data`);
                
                // Quick analysis of data structure
                if (typeof response.data === 'object') {
                    const keys = Object.keys(response.data);
                    console.log(`   📋 Top-level keys: ${keys.slice(0, 10).join(', ')}`);
                    
                    // Look for lift-related keys
                    const liftKeys = keys.filter(key => 
                        key.toLowerCase().includes('lift') || 
                        key.toLowerCase().includes('trail') ||
                        key.toLowerCase().includes('status') ||
                        key.toLowerCase().includes('open')
                    );
                    
                    if (liftKeys.length > 0) {
                        console.log(`   🎿 POTENTIAL LIFT DATA FOUND! Keys: ${liftKeys.join(', ')}`);
                        result.hasLiftData = true;
                        result.liftKeys = liftKeys;
                    }
                }
                
                result.data = response.data;
            }
            
            this.testResults.push(result);
            
        } catch (error) {
            const result = {
                url,
                description,
                error: error.message,
                success: false
            };
            
            if (error.response) {
                console.log(`   ❌ ${error.response.status} ${error.response.statusText}`);
                result.status = error.response.status;
                result.statusText = error.response.statusText;
                
                if (error.response.status === 401) {
                    console.log(`   🔐 Authentication required`);
                } else if (error.response.status === 403) {
                    console.log(`   🚫 Forbidden - might need API key`);
                } else if (error.response.status === 404) {
                    console.log(`   📍 Endpoint not found`);
                }
            } else if (error.request) {
                console.log(`   📡 No response (DNS/Network issue)`);
                result.networkError = true;
            } else {
                console.log(`   ⚠️ Request error: ${error.message}`);
            }
            
            this.testResults.push(result);
        }
    }

    async runAllTests() {
        console.log('🎿 VAIL RESORTS API DISCOVERY TEST');
        console.log('=' .repeat(60));
        console.log('Testing known and potential Vail Resorts API endpoints');
        console.log('Goal: Find working lift status APIs for Whistler Blackcomb');
        console.log('');

        // Known endpoints from current backend
        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1',
            'Current Backend API Base (from fetchLiftsDirect.js)'
        );

        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1/resort',
            'Current Backend Resort API'
        );

        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1/resort/80',
            'Whistler Blackcomb Resort (ID 80)'
        );

        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1/resort/80/lifts',
            'Whistler Blackcomb Lifts'
        );

        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1/resort/80/status',
            'Whistler Blackcomb Status'
        );

        await this.testAPI(
            'https://api-az.vailresorts.com/digital/uiservice/api/v1/resort/80/conditions',
            'Whistler Blackcomb Conditions'
        );

        // Test alternative API paths
        await this.testAPI(
            'https://api.vailresorts.com/v1/resort/80/status',
            'Alternative Vail API v1'
        );

        await this.testAPI(
            'https://api.vailresorts.com/digital/uiservice/api/v1/resort/80/status',
            'Alternative Vail API Digital'
        );

        // Test the original Azure API (even though DNS failed)
        await this.testAPI(
            'https://mtnapi-prod.azure-api.net/resortstatus/api/v1/resort/rpos/80/status',
            'Original Epic Azure API (user discovered)'
        );

        // Test Epic Pass specific APIs
        await this.testAPI(
            'https://www.epicpass.com/api/resort/80/status',
            'Epic Pass Website API'
        );

        await this.testAPI(
            'https://api.epicpass.com/v1/resort/80/status',
            'Epic Pass API'
        );

        // Test Whistler Blackcomb specific APIs
        await this.testAPI(
            'https://www.whistlerblackcomb.com/api/lifts',
            'Whistler Blackcomb Website API'
        );

        await this.testAPI(
            'https://api.whistlerblackcomb.com/v1/lifts',
            'Whistler Blackcomb Direct API'
        );

        // Test snow.com (Vail's conditions site)
        await this.testAPI(
            'https://snow.com/api/resort/whistler-blackcomb/conditions',
            'Snow.com Conditions API'
        );

        await this.testAPI(
            'https://api.snow.com/v1/resort/whistler-blackcomb/lifts',
            'Snow.com Lifts API'
        );

        // Test public/mobile APIs
        await this.testAPI(
            'https://mobile.vailresorts.com/api/resort/80/lifts',
            'Mobile Vail API'
        );

        await this.testAPI(
            'https://app.epicpass.com/api/resort/80/lifts',
            'Epic App API'
        );

        // Summary
        console.log('\n' + '='.repeat(60));
        console.log('🎿 TEST RESULTS SUMMARY');
        console.log('='.repeat(60));
        
        const successful = this.testResults.filter(r => r.success);
        const withData = this.testResults.filter(r => r.hasData);
        const withLiftData = this.testResults.filter(r => r.hasLiftData);
        
        console.log(`📊 Total tests: ${this.testResults.length}`);
        console.log(`✅ Successful (200): ${successful.length}`);
        console.log(`📄 With data: ${withData.length}`);
        console.log(`🎿 With potential lift data: ${withLiftData.length}`);
        
        if (withLiftData.length > 0) {
            console.log('\n🎉 PROMISING ENDPOINTS FOUND:');
            withLiftData.forEach(result => {
                console.log(`   ✅ ${result.description}`);
                console.log(`      URL: ${result.url}`);
                console.log(`      Lift keys: ${result.liftKeys.join(', ')}`);
            });
        }
        
        if (successful.length > 0) {
            console.log('\n📋 ALL SUCCESSFUL ENDPOINTS:');
            successful.forEach(result => {
                console.log(`   ✅ ${result.description}`);
                console.log(`      URL: ${result.url}`);
                console.log(`      Size: ${result.dataSize} chars`);
            });
        }
        
        console.log('\n🔄 NEXT STEPS:');
        if (withLiftData.length > 0) {
            console.log('1. ✅ Found potential lift data - analyze structure');
            console.log('2. 🔧 Integrate working endpoint into backend');
            console.log('3. 🗺️ Map data to LiftData.swift format');
        } else if (successful.length > 0) {
            console.log('1. 🔍 Analyze successful endpoints for lift data');
            console.log('2. 🔄 Try additional endpoint variations');
            console.log('3. 📧 Contact Vail Resorts API team if needed');
        } else {
            console.log('1. 🔐 Investigate authentication requirements');
            console.log('2. 📧 Contact Vail Resorts for API access');
            console.log('3. 🔍 Try web scraping as alternative');
        }
        
        console.log('\n' + '='.repeat(60));
    }

    // Show detailed data for promising endpoints
    showDetailedResults() {
        const withData = this.testResults.filter(r => r.success && r.data);
        
        if (withData.length > 0) {
            console.log('\n🔍 DETAILED DATA ANALYSIS:');
            console.log('='.repeat(60));
            
            withData.forEach((result, index) => {
                console.log(`\n--- Result ${index + 1}: ${result.description} ---`);
                console.log(`URL: ${result.url}`);
                console.log(`Status: ${result.status} ${result.statusText}`);
                console.log(`Data structure:`);
                console.log(JSON.stringify(result.data, null, 2).substring(0, 1000) + (JSON.stringify(result.data, null, 2).length > 1000 ? '...' : ''));
            });
        }
    }
}

// Run the comprehensive API test
async function main() {
    const tester = new VailAPITester();
    await tester.runAllTests();
    tester.showDetailedResults();
}

main().catch(console.error);