const http = require('http');

const dataPoints = Array.from({ length: 60 }).map((_, i) => {
    const isSpike = Math.random() < 0.1; // 10% chance
    const power = isSpike ? 80 + Math.random() * 40 : 20 + Math.random() * 15;
    return {
        appliance_id: 'laptop',
        power: parseFloat(power.toFixed(2)),
        timestamp: new Date(Date.now() - (60 - i) * 60000).toISOString()
    };
});

const postData = (data) => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 8000,
            path: '/ingest',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        };
        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => resolve(body));
        });
        req.on('error', reject);
        req.write(JSON.stringify(data));
        req.end();
    });
};

const sendData = async () => {
    console.log('Starting data ingestion via POST http://localhost:8000/ingest...');
    for (const data of dataPoints) {
        try {
            const res = await postData(data);
            console.log(`Sent: ${data.power}W at ${data.timestamp} - Response:`, res);
            // Wait 100ms between requests
            await new Promise(r => setTimeout(r, 100));
        } catch (e) {
            console.error('Error posting data:', e.message);
        }
    }
    console.log('Finished data ingestion!');
};

sendData();
