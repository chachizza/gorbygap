export default function handler(req, res) {
    res.json({
        message: "Vercel is working!",
        timestamp: new Date().toISOString(),
        platform: "vercel"
    });
}
