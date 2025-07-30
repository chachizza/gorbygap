#!/usr/bin/env node

/**
 * Gorby Backend - Live Lift Status Scraper
 * Scrapes live lift status from Whistler Blackcomb using Puppeteer + OpenAI
 * Follows .cursorrules: No mock data, live data only, proper error handling
 */

const puppeteer = require('puppeteer');
const fs = require('fs-extra');
const path = require('path');
const OpenAI = require('openai');
const { HttpsProxyAgent } = require('proxy-agent');
require('dotenv').config();

class LiftStatusScraper {
    constructor() {
        this.openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY
        });
        this.dataDir = path.join(__dirname, '../data');
        this.outputFile = path.join(this.dataDir, 'lifts.json');
        this.logFile = path.join(this.dataDir, 'lifts-log.json');
    }

    log(message, level = 'info') {
        const timestamp = new Date().toISOString();
        const logEntry = { timestamp, level, message };
        
        console.log(`[${timestamp}] ${level.toUpperCase()}: ${message}`);
        
        // Append to log file
        this.appendToLogFile(logEntry);
    }

    async appendToLogFile(logEntry) {
        try {
            let logs = [];
            if (await fs.pathExists(this.logFile)) {
                logs = await fs.readJson(this.logFile);
            }
            logs.push(logEntry);
            
            // Keep only last 100 log entries
            if (logs.length > 100) {
                logs = logs.slice(-100);
            }
            
            await fs.writeJson(this.logFile, logs, { spaces: 2 });
        } catch (error) {
            console.error('Failed to write to log file:', error.message);
        }
    }

    async scrapeWhistlerLifts() {
        let browser;
        try {
            this.log('Starting lift status scrape from Whistler Peak');
            
            // Enhanced browser simulation to bypass IP blocking
            const userAgents = [
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
            ];
            
            const randomUserAgent = userAgents[Math.floor(Math.random() * userAgents.length)];
            this.log(`Using user agent: ${randomUserAgent}`);

            browser = await puppeteer.launch({
                headless: 'new',
                executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || undefined,
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                    '--single-process',
                    '--disable-gpu',
                    '--disable-web-security',
                    '--disable-features=VizDisplayCompositor',
                    '--run-all-compositor-stages-before-draw',
                    '--disable-background-timer-throttling',
                    '--disable-renderer-backgrounding',
                    '--disable-backgrounding-occluded-windows',
                    '--disable-ipc-flooding-protection',
                    '--disable-blink-features=AutomationControlled',
                    '--disable-extensions',
                    '--disable-plugins'
                ],
                timeout: 60000
            });

            const page = await browser.newPage();
            
            // Set random user agent and enhanced headers to bypass IP blocking
            await page.setUserAgent(randomUserAgent);
            await page.setExtraHTTPHeaders({
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
                'Accept-Language': 'en-US,en;q=0.9,en;q=0.8',
                'Accept-Encoding': 'gzip, deflate, br',
                'DNT': '1',
                'Connection': 'keep-alive',
                'Upgrade-Insecure-Requests': '1',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'none',
                'Sec-Fetch-User': '?1',
                'Cache-Control': 'max-age=0'
            });
            
            // Add random delay to simulate human behavior
            const randomDelay = Math.floor(Math.random() * 3000) + 1000; // 1-4 seconds
            this.log(`Adding random delay: ${randomDelay}ms`);
            await new Promise(resolve => setTimeout(resolve, randomDelay));
            
            this.log('Navigating to Whistler Peak live lifts page');
            await page.goto(process.env.WHISTLER_LIFTS_URL, { 
                waitUntil: 'domcontentloaded',
                timeout: 45000 
            });

            // Wait for dynamic content to load
            await page.waitForTimeout(3000);
            
            this.log('Extracting HTML content - all lifts are on one page');
            
            // Get all lifts from the single page (no toggle needed!)
            await page.waitForTimeout(2000);
            this.log('Scraping all lifts from unified page');
            const htmlContent = await page.content();
            
            // Take screenshot for debugging if needed
            if (process.env.NODE_ENV === 'development') {
                await page.screenshot({ 
                    path: path.join(this.dataDir, 'all-lifts-screenshot.png'),
                    fullPage: true 
                });
            }
            
            this.log('Processing all lifts with OpenAI');
            const liftData = await this.parseWithOpenAI(htmlContent, 'Both');
            
            return liftData;

        } catch (error) {
            this.log(`Scraping error: ${error.message}`, 'error');
            throw error;
        } finally {
            if (browser) {
                await browser.close();
            }
        }
    }

    async parseWithOpenAI(htmlContent, targetMountain = 'Whistler') {
        try {
                        const prompt = `
You are a web scraping assistant. Parse this HTML from Whistler Peak's live lift status page.

TASK: Extract ALL lifts from the page and categorize each by mountain based on lift names.

The HTML uses this SPECIFIC structure:
- Each lift is in a div with class "lift-container"
- Status is determined by additional CSS classes:
  * "openContainer" = Open
  * "closedContainer" = Closed  
  * "holdContainer" = On Hold
- Lift names are in divs with class "liftName"

EXAMPLE STRUCTURE:
<div class="lift-container openContainer">
  <div class="liftName openName"><div>Creekside Gondola</div></div>
</div>
<div class="lift-container closedContainer">
  <div class="liftName closedName">Harmony 6 Express</div>
</div>

Extract ALL lifts in this exact JSON format:
{
  "lastUpdated": "${new Date().toISOString()}",
  "source": "whistlerpeak.com",
  "liftCount": 0,
  "lifts": [
    {
      "liftName": "Creekside Gondola",
      "status": "Open",
      "mountain": "Whistler",
      "type": "Gondola",
      "lastUpdated": "${new Date().toISOString()}"
    },
    {
      "liftName": "Magic Chair",
      "status": "Closed",
      "mountain": "Blackcomb",
      "type": "Magic Chair",
      "lastUpdated": "${new Date().toISOString()}"
    }
  ]
}

CRITICAL RULES:
1. Find ALL div elements with class "lift-container" - there should be 25+ lifts total
2. Extract lift name from the "liftName" div inside each container
3. Determine status from container CSS classes: openContainer=Open, closedContainer=Closed, holdContainer=On Hold
4. Categorize mountain based on lift names:
   * WHISTLER: Creekside, Fitzsimmons, Peak Express, Big Red, Olympic, Franz's, Emerald, Symphony, Whistler Gondola, Garbanzo, Harmony
   * BLACKCOMB: Excalibur, Magic, Jersey Cream, Crystal Ridge, Glacier, 7th Heaven, Blackcomb Gondola, Catskinner, Excelerator, Showcase
   * BOTH: P2P Gondola (Peak 2 Peak connects both mountains)
5. Infer type from name: Express=Express Chair, Gondola=Gondola, T-Bar=T-Bar, Magic=Magic Chair, etc.
6. Count total lifts and set liftCount accurately (should be 25+)
7. Return ONLY the JSON object, no markdown formatting
8. DO NOT MISS ANY LIFTS - scan the entire HTML thoroughly

HTML Content:
${htmlContent}
`;

            const response = await this.openai.chat.completions.create({
                model: "gpt-3.5-turbo",
                messages: [
                    {
                        role: "system",
                        content: "You are a precise web scraping assistant that extracts structured data from HTML. Always return valid JSON."
                    },
                    {
                        role: "user",
                        content: prompt
                    }
                ],
                max_tokens: 2000,
                temperature: 0.1
            });

            let jsonText = response.choices[0].message.content.trim();
            this.log(`OpenAI response: ${jsonText.substring(0, 200)}...`);
            
            // Remove markdown code blocks if present
            if (jsonText.startsWith('```json')) {
                jsonText = jsonText.replace(/^```json\s*/, '').replace(/\s*```$/, '');
            } else if (jsonText.startsWith('```')) {
                jsonText = jsonText.replace(/^```\s*/, '').replace(/\s*```$/, '');
            }
            
            // Parse and validate JSON
            const parsedData = JSON.parse(jsonText);
            
            // Handle both array format (legacy) and object format (new)
            let liftData;
            if (Array.isArray(parsedData)) {
                // Legacy format - wrap in object structure
                liftData = {
                    lastUpdated: new Date().toISOString(),
                    source: 'whistlerpeak.com',
                    liftCount: parsedData.length,
                    lifts: parsedData
                };
            } else if (parsedData.lifts && Array.isArray(parsedData.lifts)) {
                // New format - use as is
                liftData = parsedData;
                liftData.liftCount = parsedData.lifts.length; // Ensure count is correct
            } else {
                throw new Error('OpenAI response format is invalid - expected array or object with lifts property');
            }

            this.log(`Successfully parsed ${liftData.lifts.length} lifts for ${targetMountain}`);
            return liftData;

        } catch (error) {
            this.log(`OpenAI parsing error: ${error.message}`, 'error');
            throw error;
        }
    }

    async saveData(data) {
        try {
            await fs.ensureDir(this.dataDir);
            
            // Handle both array format (legacy) and object format (new)
            let outputData;
            if (Array.isArray(data)) {
                // Legacy format
                outputData = {
                    lastUpdated: new Date().toISOString(),
                    source: 'whistlerpeak.com',
                    liftCount: data.length,
                    lifts: data
                };
            } else {
                // New format - data already has the correct structure
                outputData = {
                    ...data,
                    lastUpdated: new Date().toISOString(),
                    source: 'whistlerpeak.com'
                };
            }

            await fs.writeJson(this.outputFile, outputData, { spaces: 2 });
            this.log(`Saved ${outputData.liftCount} lifts to ${this.outputFile}`);
            
            return outputData;
        } catch (error) {
            this.log(`Save error: ${error.message}`, 'error');
            throw error;
        }
    }

    async run() {
        try {
            this.log('=== Starting Gorby Lift Status Scraper ===');
            
            // Ensure we have required environment variables
            if (!process.env.OPENAI_API_KEY) {
                throw new Error('OPENAI_API_KEY environment variable is required');
            }

            const liftData = await this.scrapeWhistlerLifts();
            const savedData = await this.saveData(liftData);
            
            this.log('=== Scraping completed successfully ===');
            return savedData;

        } catch (error) {
            this.log(`Fatal error: ${error.message}`, 'error');
            process.exit(1);
        }
    }
}

// Run if called directly
if (require.main === module) {
    const scraper = new LiftStatusScraper();
    scraper.run();
}

module.exports = LiftStatusScraper; 