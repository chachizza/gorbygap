#!/usr/bin/env node

/**
 * Basic Backend Test - No OpenAI Required
 * Tests core functionality without API costs
 */

const puppeteer = require('puppeteer');
const fs = require('fs-extra');
const path = require('path');

class BasicTester {
    constructor() {
        this.dataDir = path.join(__dirname, '../data');
    }

    log(message) {
        const timestamp = new Date().toISOString();
        console.log(`[${timestamp}] ${message}`);
    }

    async testPuppeteer() {
        let browser;
        try {
            this.log('Testing Puppeteer (without OpenAI)...');
            
            browser = await puppeteer.launch({
                headless: true,
                args: ['--no-sandbox', '--disable-setuid-sandbox']
            });

            const page = await browser.newPage();
            await page.goto('https://httpbin.org/json', { waitUntil: 'networkidle2' });
            
            const content = await page.content();
            this.log(`✅ Puppeteer working! Content length: ${content.length}`);
            
            return true;

        } catch (error) {
            this.log(`❌ Puppeteer error: ${error.message}`);
            return false;
        } finally {
            if (browser) {
                await browser.close();
            }
        }
    }

    async testDataSave() {
        try {
            this.log('Testing data saving...');
            
            const testData = {
                lastUpdated: new Date().toISOString(),
                source: 'test',
                liftCount: 2,
                lifts: [
                    {
                        liftName: "Test Express",
                        status: "Open",
                        mountain: "Whistler",
                        type: "Express Chair",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Demo Gondola",
                        status: "Closed",
                        mountain: "Blackcomb", 
                        type: "Gondola",
                        lastUpdated: new Date().toISOString()
                    }
                ]
            };

            await fs.ensureDir(this.dataDir);
            const testFile = path.join(this.dataDir, 'test-lifts.json');
            await fs.writeJson(testFile, testData, { spaces: 2 });
            
            this.log(`✅ Data saving working! File: ${testFile}`);
            return true;

        } catch (error) {
            this.log(`❌ Data save error: ${error.message}`);
            return false;
        }
    }

    async run() {
        this.log('=== Gorby Backend Basic Test ===');
        
        const tests = [
            await this.testPuppeteer(),
            await this.testDataSave()
        ];

        const passed = tests.filter(t => t).length;
        const total = tests.length;

        this.log(`=== Test Results: ${passed}/${total} passed ===`);
        
        if (passed === total) {
            this.log('🎉 Backend core functionality is working!');
            this.log('💡 Next: Set up OpenAI billing to enable live scraping');
        } else {
            this.log('⚠️  Some tests failed - check the logs above');
        }
    }
}

// Run if called directly
if (require.main === module) {
    const tester = new BasicTester();
    tester.run();
}

module.exports = BasicTester; 