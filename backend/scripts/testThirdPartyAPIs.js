#!/usr/bin/env node

/**
 * Third-Party Whistler Lift Status Testing
 * Tests third-party sites that may provide lift status data
 */

const axios = require('axios');

class ThirdPartyAPITester {
    constructor() {
        this.results = [];
    }

    async testAPI(url, description, headers = {}) {
        console.log(`\n📡 Testing: ${description}`);
        console.log(`   URL: ${url}`);
        
        try {
            const response = await axios.get(url, {
                headers: {
                    'User-Agent': 'Gorby-App/1.0 (iOS; Mountain Data)',
                    'Accept': 'application/json, text/html, */*',
                    'Accept-Encoding': 'gzip, deflate, br',
                    ...headers
                },
                timeout: 15000,
                validateStatus: function (status) {
                    return status < 500;
                }
            });

            console.log(`   ✅ ${response.status} ${response.statusText}`);
            console.log(`   📏 Size: ${JSON.stringify(response.data).length} chars`);
            console.log(`   📋 Content-Type: ${response.headers['content-type']}`);
            
            if (response.status === 200) {
                console.log(`   🎉 SUCCESS! Got data`);
                
                // Analyze the response
                this.analyzeResponse(response.data, description);
                
                return { 
                    success: true, 
                    data: response.data, 
                    url: url,
                    description: description,
                    contentType: response.headers['content-type']
                };
            }
            
        } catch (error) {
            console.log(`   ❌ Error: ${error.message.split('\n')[0]}`);
            return { success: false, error: error.message, url: url };
        }
    }

    analyzeResponse(data, description) {
        if (typeof data === 'string') {
            // HTML or text response
            if (data.includes('lift') || data.includes('status') || data.includes('open') || data.includes('closed')) {
                console.log(`   🎿 Contains lift-related content!`);
                
                // Look for JSON data embedded in HTML
                const jsonMatch = data.match(/(?:var|const|let)\s+\w+\s*=\s*(\{.*?\});?/gs);
                if (jsonMatch) {
                    console.log(`   📄 Found embedded JSON data (${jsonMatch.length} matches)`);
                }
                
                // Look for API endpoints in the HTML
                const apiMatch = data.match(/(?:api|endpoint|url).*?['"](https?:\/\/[^'"]+)['"]/gi);
                if (apiMatch) {
                    console.log(`   🔗 Found potential API URLs: ${apiMatch.slice(0, 3).join(', ')}`);
                }
                
                console.log(`   📝 Sample content: ${data.substring(0, 200)}...`);
            } else {
                console.log(`   📄 Text/HTML response (no obvious lift data)`);
            }
        } else if (typeof data === 'object') {
            // JSON response
            console.log(`   📊 JSON response - analyzing structure...`);
            
            if (Array.isArray(data)) {
                console.log(`   📋 Array with ${data.length} items`);
                if (data.length > 0) {
                    console.log(`   🔍 First item: ${JSON.stringify(data[0], null, 2).substring(0, 200)}...`);
                }
            } else {
                const keys = Object.keys(data);
                console.log(`   📋 Object keys: ${keys.slice(0, 10).join(', ')}`);
                
                // Look for lift-related keys
                const liftKeys = keys.filter(key => 
                    key.toLowerCase().includes('lift') || 
                    key.toLowerCase().includes('trail') ||
                    key.toLowerCase().includes('status') ||
                    key.toLowerCase().includes('open') ||
                    key.toLowerCase().includes('closed')
                );
                
                if (liftKeys.length > 0) {
                    console.log(`   🎿 LIFT DATA FOUND! Keys: ${liftKeys.join(', ')}`);
                    
                    // Show sample of lift data
                    liftKeys.slice(0, 3).forEach(key => {
                        console.log(`   📄 ${key}: ${JSON.stringify(data[key], null, 2).substring(0, 150)}...`);
                    });
                }
            }
        }
    }

    async runTests() {
        console.log('🎿 THIRD-PARTY WHISTLER LIFT STATUS TESTING');
        console.log('='.repeat(60));
        console.log('Testing third-party sites that may track Whistler lift status');
        console.log('');

        // Test whistlerlifts.com
        await this.testAPI('https://whistlerlifts.com/', 'Whistler Lifts Main Page');
        await this.testAPI('https://whistlerlifts.com/api/lifts', 'Whistler Lifts API');
        await this.testAPI('https://whistlerlifts.com/api/status', 'Whistler Lifts Status API');
        await this.testAPI('https://whistlerlifts.com/data/lifts.json', 'Whistler Lifts JSON Data');
        await this.testAPI('https://whistlerlifts.com/lifts.json', 'Whistler Lifts Direct JSON');

        // Test whistlerpeak.com / whistleropen.com
        await this.testAPI('https://whistlerpeak.com/', 'Whistler Peak Main Page');
        await this.testAPI('https://whistleropen.com/', 'Whistler Open Main Page');
        await this.testAPI('https://whistlerpeak.com/api/lifts', 'Whistler Peak Lifts API');
        await this.testAPI('https://whistlerpeak.com/api/status', 'Whistler Peak Status API');
        await this.testAPI('https://whistlerpeak.com/data/lifts.json', 'Whistler Peak JSON Data');

        // Test potential API endpoints for these sites
        await this.testAPI('https://api.whistlerpeak.com/lifts', 'Whistler Peak API Subdomain');
        await this.testAPI('https://data.whistlerpeak.com/lifts.json', 'Whistler Peak Data Subdomain');

        // Test other potential third-party services
        await this.testAPI('https://opensnow.com/api/location/whistler-blackcomb', 'OpenSnow Whistler API');
        await this.testAPI('https://www.onthesnow.com/api/resort/whistler-blackcomb', 'OnTheSnow API');
        await this.testAPI('https://skiresort.info/api/ski-resort/whistler-blackcomb/', 'SkiResort.info API');

        // Test if Whistler Blackcomb has any public endpoints for conditions
        await this.testAPI('https://www.whistlerblackcomb.com/api/conditions', 'WB Conditions API');
        await this.testAPI('https://www.whistlerblackcomb.com/api/lifts', 'WB Lifts API');
        await this.testAPI('https://www.whistlerblackcomb.com/the-mountain/mountain-conditions/lift-terrain-status.aspx', 'WB Lift Status Page');

        console.log('\n' + '='.repeat(60));
        console.log('🔍 THIRD-PARTY API TEST RESULTS');
        console.log('='.repeat(60));
        
        const successful = this.results.filter(r => r && r.success);
        const withLiftData = this.results.filter(r => r && r.success && r.description.includes('LIFT DATA FOUND'));
        
        console.log(`📊 Total tests completed`);
        console.log(`✅ Successful responses: ${successful.length}`);
        console.log(`🎿 With lift data: ${withLiftData.length}`);
        
        if (withLiftData.length > 0) {
            console.log('\n🎉 PROMISING ENDPOINTS WITH LIFT DATA:');
            withLiftData.forEach(result => {
                console.log(`   ✅ ${result.description}`);
                console.log(`      URL: ${result.url}`);
            });
        }
        
        if (successful.length > 0) {
            console.log('\n📋 ALL SUCCESSFUL ENDPOINTS:');
            successful.forEach(result => {
                console.log(`   ✅ ${result.description} - ${result.contentType}`);
                console.log(`      URL: ${result.url}`);
            });
        }
        
        console.log('\n🔄 NEXT STEPS:');
        if (withLiftData.length > 0) {
            console.log('1. ✅ Analyze lift data structure from successful endpoints');
            console.log('2. 🔧 Create parser for the data format');
            console.log('3. 🗺️ Map to LiftData.swift format');
            console.log('4. 🚀 Integrate into backend');
        } else {
            console.log('1. 🔍 Analyze successful HTML pages for embedded data');
            console.log('2. 🕷️ Consider web scraping approach');
            console.log('3. 📧 Contact third-party site owners for API access');
            console.log('4. 🔄 Continue searching for other data sources');
        }
        
        this.results = this.results.filter(r => r && r.success);
    }

    async showDetailedResults() {
        if (this.results.length > 0) {
            console.log('\n📄 DETAILED RESPONSE ANALYSIS:');
            console.log('='.repeat(60));
            
            this.results.slice(0, 3).forEach((result, index) => {
                console.log(`\n--- ${result.description} ---`);
                console.log(`URL: ${result.url}`);
                console.log(`Content-Type: ${result.contentType}`);
                console.log('Data sample:');
                
                if (typeof result.data === 'string') {
                    console.log(result.data.substring(0, 500) + '...');
                } else {
                    console.log(JSON.stringify(result.data, null, 2).substring(0, 500) + '...');
                }
            });
        }
    }
}

// Run the tests
async function main() {
    const tester = new ThirdPartyAPITester();
    await tester.runTests();
    await tester.showDetailedResults();
}

main().catch(console.error);