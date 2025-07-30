import puppeteer from 'puppeteer';

export default async function handler(req, res) {
    if (req.method === 'POST') {
        // Manual refresh endpoint
        return handleRefresh(req, res);
    }
    
    // GET request - test scraping
    try {
        console.log('Lifts data requested - testing ChatGPT scraping');
        
        // Try to scrape directly from Vercel
        const scrapedData = await testScraping();
        
        if (scrapedData.success) {
            res.json({
                lastUpdated: new Date().toISOString(),
                source: 'vercel-chatgpt-test',
                liftCount: scrapedData.liftCount || 2,
                lifts: scrapedData.lifts || [],
                message: 'SUCCESS: Vercel can access Whistler website!',
                ip_blocking: false
            });
        } else {
            res.json({
                lastUpdated: new Date().toISOString(),
                source: 'vercel-fallback', 
                liftCount: 2,
                lifts: [
                    {
                        liftName: "Peak Express",
                        status: "Open",
                        mountain: "Whistler", 
                        type: "Express Chair",
                        lastUpdated: new Date().toISOString()
                    },
                    {
                        liftName: "Blackcomb Gondola",
                        status: "Open", 
                        mountain: "Blackcomb",
                        type: "Gondola",
                        lastUpdated: new Date().toISOString()
                    }
                ],
                message: 'BLOCKED: Vercel IPs also blocked by Whistler',
                ip_blocking: true,
                error: scrapedData.error
            });
        }
    } catch (error) {
        console.error('Error in lifts endpoint:', error);
        res.status(500).json({ 
            error: 'Server error',
            message: error.message 
        });
    }
}

async function testScraping() {
    let browser;
    try {
        console.log('Starting Vercel scraping test...');
        
        browser = await puppeteer.launch({
            headless: 'new',
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--single-process',
                '--disable-gpu',
                '--disable-web-security'
            ]
        });

        const page = await browser.newPage();
        
        // Set realistic headers
        await page.setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        await page.setExtraHTTPHeaders({
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        });
        
        console.log('Navigating to Whistler website...');
        await page.goto('https://whistlerpeak.com/livelifts/', { 
            waitUntil: 'domcontentloaded',
            timeout: 30000 
        });

        console.log('SUCCESS: Vercel can access Whistler website!');
        
        // Get page title as proof
        const title = await page.title();
        console.log('Page title:', title);
        
        // Basic test - just prove we can access the site
        return {
            success: true,
            message: 'Vercel bypassed IP blocking!',
            pageTitle: title,
            liftCount: 2, // Mock for now since we just proved access
            lifts: [
                {
                    liftName: "Peak Express", 
                    status: "Open",
                    mountain: "Whistler",
                    type: "Express Chair",
                    lastUpdated: new Date().toISOString()
                },
                {
                    liftName: "Blackcomb Gondola",
                    status: "Open", 
                    mountain: "Blackcomb", 
                    type: "Gondola",
                    lastUpdated: new Date().toISOString()
                }
            ]
        };

    } catch (error) {
        console.error('Scraping failed:', error.message);
        return {
            success: false,
            error: error.message
        };
    } finally {
        if (browser) {
            await browser.close();
        }
    }
}

async function handleRefresh(req, res) {
    const result = await testScraping();
    res.json({ 
        status: 'refresh triggered', 
        platform: 'vercel',
        scraping_result: result
    });
}
