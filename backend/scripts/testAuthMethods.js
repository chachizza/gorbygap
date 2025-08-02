#!/usr/bin/env node

/**
 * Vail Resorts API Authentication Testing
 * Tests various authentication methods for the Vail API
 */

const axios = require('axios');

class VailAuthTester {
    constructor() {
        this.baseURL = 'https://api-az.vailresorts.com/digital/uiservice/api/v1';
        this.testEndpoint = '/resort/80/lifts';
    }

    async testAuth(description, headers = {}) {
        console.log(`\n🔐 Testing: ${description}`);
        const url = this.baseURL + this.testEndpoint;
        
        try {
            const response = await axios.get(url, {
                headers: {
                    'User-Agent': 'Gorby-App/1.0 (iOS; Mountain Data)',
                    'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    ...headers
                },
                timeout: 10000,
                validateStatus: function (status) {
                    return status < 500;
                }
            });

            console.log(`   Status: ${response.status} ${response.statusText}`);
            console.log(`   Data size: ${JSON.stringify(response.data).length} chars`);
            
            if (response.status === 200) {
                console.log(`   🎉 SUCCESS! Authentication worked!`);
                console.log(`   📄 Sample data:`, JSON.stringify(response.data, null, 2).substring(0, 500));
                return { success: true, data: response.data };
            } else if (response.status === 401) {
                console.log(`   🔐 Still unauthorized - try different auth method`);
            } else if (response.status === 403) {
                console.log(`   🚫 Forbidden - might need different API key or permissions`);
            }
            
        } catch (error) {
            if (error.response) {
                console.log(`   ❌ ${error.response.status} ${error.response.statusText}`);
            } else {
                console.log(`   ❌ Network error: ${error.message}`);
            }
        }
        
        return { success: false };
    }

    async runAuthTests() {
        console.log('🔐 VAIL RESORTS API AUTHENTICATION TESTING');
        console.log('='.repeat(60));
        console.log(`Testing: ${this.baseURL}${this.testEndpoint}`);
        console.log('');

        // Test 1: No authentication (baseline)
        await this.testAuth('No authentication (baseline)');

        // Test 2: Common API key headers
        await this.testAuth('API Key in Authorization header', {
            'Authorization': 'Bearer your-api-key-here'
        });

        await this.testAuth('API Key in X-API-Key header', {
            'X-API-Key': 'your-api-key-here'
        });

        await this.testAuth('API Key in X-Auth-Token header', {
            'X-Auth-Token': 'your-api-key-here'
        });

        // Test 3: Subscription key (Azure API Management style)
        await this.testAuth('Azure Subscription Key', {
            'Ocp-Apim-Subscription-Key': 'your-subscription-key'
        });

        await this.testAuth('X-Subscription-Key header', {
            'X-Subscription-Key': 'your-subscription-key'
        });

        // Test 4: Epic Pass specific headers
        await this.testAuth('Epic Pass App headers', {
            'X-Epic-App': 'mobile',
            'X-Epic-Version': '1.0'
        });

        await this.testAuth('Epic Resort ID header', {
            'X-Resort-Id': '80',
            'X-Resort-Code': 'whistler-blackcomb'
        });

        // Test 5: Common mobile app headers
        await this.testAuth('Mobile app simulation', {
            'User-Agent': 'Epic-Mobile-App/1.0 (iOS; iPhone; Scale/2.0)',
            'X-Requested-With': 'com.vailresorts.epic',
            'X-Client-Type': 'mobile'
        });

        // Test 6: Referer-based access
        await this.testAuth('With Epic Pass referer', {
            'Referer': 'https://www.epicpass.com',
            'Origin': 'https://www.epicpass.com'
        });

        await this.testAuth('With Whistler Blackcomb referer', {
            'Referer': 'https://www.whistlerblackcomb.com',
            'Origin': 'https://www.whistlerblackcomb.com'
        });

        // Test 7: Try different Accept headers
        await this.testAuth('XML Accept header', {
            'Accept': 'application/xml, text/xml'
        });

        await this.testAuth('Any Accept header', {
            'Accept': '*/*'
        });

        console.log('\n' + '='.repeat(60));
        console.log('🔍 AUTHENTICATION ANALYSIS COMPLETE');
        console.log('='.repeat(60));
        console.log('');
        console.log('📋 Common API Authentication Methods for Vail/Epic:');
        console.log('1. 🔑 API Key registration through Vail Developer Portal');
        console.log('2. 🎫 Epic Pass holder authentication tokens');
        console.log('3. 📱 Mobile app client credentials');
        console.log('4. 🏢 Resort partner/business API access');
        console.log('5. 🌐 Public endpoints (if they exist)');
        console.log('');
        console.log('🔄 Next Steps:');
        console.log('1. 📧 Contact Vail Resorts API support for developer access');
        console.log('2. 🔍 Look for Vail Developer Portal or API documentation');
        console.log('3. 🎫 Investigate Epic Pass app authentication flow');
        console.log('4. 🕷️ Consider web scraping as backup option');
        console.log('5. 🔄 Try public/unauthenticated endpoints (if any exist)');
    }

    async testPublicEndpoints() {
        console.log('\n🌐 TESTING POTENTIAL PUBLIC ENDPOINTS');
        console.log('='.repeat(50));

        const publicEndpoints = [
            '/public/resort/80/lifts',
            '/resort/80/public/lifts',
            '/api/public/resort/80/lifts',
            '/resort/80/lifts/public',
            '/resort/80/conditions/public',
            '/guest/resort/80/lifts',
            '/open/resort/80/lifts'
        ];

        for (const endpoint of publicEndpoints) {
            console.log(`\n📡 Testing: ${this.baseURL}${endpoint}`);
            
            try {
                const response = await axios.get(this.baseURL + endpoint, {
                    headers: {
                        'User-Agent': 'Gorby-App/1.0 (iOS; Mountain Data)',
                        'Accept': 'application/json'
                    },
                    timeout: 5000,
                    validateStatus: () => true
                });

                console.log(`   Status: ${response.status} ${response.statusText}`);
                
                if (response.status === 200) {
                    console.log(`   🎉 PUBLIC ENDPOINT FOUND!`);
                    console.log(`   📄 Data: ${JSON.stringify(response.data, null, 2).substring(0, 300)}...`);
                }
            } catch (error) {
                console.log(`   ❌ Failed: ${error.message.split('\n')[0]}`);
            }
        }
    }
}

// Run the authentication tests
async function main() {
    const tester = new VailAuthTester();
    await tester.runAuthTests();
    await tester.testPublicEndpoints();
}

main().catch(console.error);