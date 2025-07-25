#!/usr/bin/env node

/**
 * Gorby Backend - Live Webcam Feed Scraper
 * Scrapes live webcam feeds from Whistler Blackcomb using Puppeteer + OpenAI
 * Follows .cursorrules: No mock data, live data only, proper error handling
 */

const puppeteer = require('puppeteer');
const fs = require('fs-extra');
const path = require('path');
const OpenAI = require('openai');
require('dotenv').config();

class WebcamScraper {
    constructor() {
        this.openai = new OpenAI({
            apiKey: process.env.OPENAI_API_KEY
        });
        this.dataDir = path.join(__dirname, '../data');
        this.outputFile = path.join(this.dataDir, 'webcams.json');
        this.logFile = path.join(this.dataDir, 'webcams-log.json');
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

    async scrapeWhistlerWebcams() {
        let browser;
        try {
            this.log('Starting webcam scrape from Whistler Blackcomb');
            
            browser = await puppeteer.launch({
                headless: true,
                args: ['--no-sandbox', '--disable-setuid-sandbox'],
                timeout: parseInt(process.env.SCRAPING_TIMEOUT_MS) || 30000
            });

            const page = await browser.newPage();
            
            // Set user agent to avoid blocking
            await page.setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
            
            this.log('Navigating to Whistler Blackcomb webcams page');
            await page.goto(process.env.WHISTLER_WEBCAMS_URL, { 
                waitUntil: 'networkidle2',
                timeout: 30000 
            });

            // Wait for dynamic content and iframes to load
            await page.waitForTimeout(5000);
            
            this.log('Extracting HTML content and iframe sources');
            
            // Get main page content
            const htmlContent = await page.content();
            
            // Extract iframe sources and image URLs
            const mediaData = await page.evaluate(() => {
                const iframes = Array.from(document.querySelectorAll('iframe'));
                const images = Array.from(document.querySelectorAll('img[src*="cam"], img[src*="webcam"], img[src*="camera"]'));
                
                return {
                    iframes: iframes.map(iframe => ({
                        src: iframe.src,
                        title: iframe.title || iframe.getAttribute('alt') || '',
                        width: iframe.width,
                        height: iframe.height
                    })),
                    images: images.map(img => ({
                        src: img.src,
                        alt: img.alt || '',
                        title: img.title || ''
                    }))
                };
            });
            
            // Take screenshot for debugging if needed
            if (process.env.NODE_ENV === 'development') {
                await page.screenshot({ 
                    path: path.join(this.dataDir, 'webcams-screenshot.png'),
                    fullPage: true 
                });
            }

            this.log('Processing HTML with OpenAI');
            const webcamData = await this.parseWithOpenAI(htmlContent, mediaData);
            
            return webcamData;

        } catch (error) {
            this.log(`Scraping error: ${error.message}`, 'error');
            throw error;
        } finally {
            if (browser) {
                await browser.close();
            }
        }
    }

    async parseWithOpenAI(htmlContent, mediaData) {
        try {
            const prompt = `
You are a web scraping assistant. Parse this HTML content from a ski resort webcam page and extract live webcam information.

Extract webcam data in this exact JSON format:
[
  {
    "name": "Roundhouse Lodge",
    "imageUrl": "https://example.com/camera1.jpg",
    "location": "Whistler Mountain",
    "isLive": true,
    "lastUpdated": "2025-01-24T15:30:00Z"
  }
]

Additional media data found:
Iframes: ${JSON.stringify(mediaData.iframes, null, 2)}
Images: ${JSON.stringify(mediaData.images, null, 2)}

Rules:
1. Only include actual mountain/ski area webcams
2. Extract clear, descriptive names for each camera location
3. Use the best available image URL (prioritize high resolution)
4. Location should indicate which mountain or area (Whistler, Blackcomb, Base, Peak, etc.)
5. Set isLive to true if it appears to be a live feed, false for static images
6. Use current timestamp for lastUpdated if not available
7. Return ONLY the JSON array, no explanatory text

HTML Content to parse:
${htmlContent.substring(0, 8000)} ${htmlContent.length > 8000 ? '...[truncated]' : ''}
            `;

            const response = await this.openai.chat.completions.create({
                model: "gpt-3.5-turbo",
                messages: [
                    {
                        role: "system",
                        content: "You are a precise web scraping assistant that extracts structured webcam data from HTML. Always return valid JSON."
                    },
                    {
                        role: "user",
                        content: prompt
                    }
                ],
                max_tokens: 2000,
                temperature: 0.1
            });

            const jsonText = response.choices[0].message.content.trim();
            this.log(`OpenAI response: ${jsonText.substring(0, 200)}...`);
            
            // Parse and validate JSON
            const webcamData = JSON.parse(jsonText);
            
            if (!Array.isArray(webcamData)) {
                throw new Error('OpenAI response is not an array');
            }

            this.log(`Successfully parsed ${webcamData.length} webcams`);
            return webcamData;

        } catch (error) {
            this.log(`OpenAI parsing error: ${error.message}`, 'error');
            throw error;
        }
    }

    async saveData(data) {
        try {
            await fs.ensureDir(this.dataDir);
            
            const outputData = {
                lastUpdated: new Date().toISOString(),
                source: 'whistlerblackcomb.com',
                webcamCount: data.length,
                webcams: data
            };

            await fs.writeJson(this.outputFile, outputData, { spaces: 2 });
            this.log(`Saved ${data.length} webcams to ${this.outputFile}`);
            
            return outputData;
        } catch (error) {
            this.log(`Save error: ${error.message}`, 'error');
            throw error;
        }
    }

    async run() {
        try {
            this.log('=== Starting Gorby Webcam Scraper ===');
            
            // Ensure we have required environment variables
            if (!process.env.OPENAI_API_KEY) {
                throw new Error('OPENAI_API_KEY environment variable is required');
            }

            const webcamData = await this.scrapeWhistlerWebcams();
            const savedData = await this.saveData(webcamData);
            
            this.log('=== Webcam scraping completed successfully ===');
            return savedData;

        } catch (error) {
            this.log(`Fatal error: ${error.message}`, 'error');
            process.exit(1);
        }
    }
}

// Run if called directly
if (require.main === module) {
    const scraper = new WebcamScraper();
    scraper.run();
}

module.exports = WebcamScraper; 