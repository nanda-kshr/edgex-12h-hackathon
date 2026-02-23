const { MongoClient } = require("mongodb");
require('dotenv').config();

const uri = process.env.MONGO_URI;

async function run() {
    const client = new MongoClient(uri);
    try {
        await client.connect();
        const db = client.db('energy_db');

        // Add an alert
        const alert = {
            timestamp: new Date(),
            appliance_id: 'laptop',
            power: 145.2,
            threshold: 80.0,
            message: 'SPIKE DETECTED! 145.2W > 80.00W'
        };

        await db.collection('alerts').insertOne(alert);
        console.log('Successfully added a manual alert!');
    } finally {
        await client.close();
    }
}

run().catch(console.dir);
