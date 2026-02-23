import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Reading, ReadingDocument } from './schemas/reading.schema';
import { Alert, AlertDocument } from './schemas/alert.schema';
import { Setting, SettingDocument } from './schemas/setting.schema';
import { Forecast, ForecastDocument } from './schemas/forecast.schema';
import { EnergyReadingDto } from './dto/energy-reading.dto';

@Injectable()
export class EnergyService {
    constructor(
        @InjectModel(Reading.name) private readingModel: Model<ReadingDocument>,
        @InjectModel(Alert.name) private alertModel: Model<AlertDocument>,
        @InjectModel(Setting.name) private settingModel: Model<SettingDocument>,
        @InjectModel(Forecast.name) private forecastModel: Model<ForecastDocument>,
    ) { }

    async ingestData(data: EnergyReadingDto) {
        // 1. Fetch Offset from DB
        const setting = await this.settingModel.findOne({ key: 'power_offset' }).exec();
        const offset = setting?.value || 0;

        // 2. Apply Offset
        const power = data.power + offset;

        // 3. Set timestamp if missing
        const timestamp = data.timestamp ? new Date(data.timestamp) : new Date();

        // 4. Store Raw Data
        await this.readingModel.create({
            appliance_id: data.appliance_id,
            power,
            timestamp,
        });

        // 5. REAL-TIME SPIKE CHECK
        const lookupTime = new Date(timestamp);
        lookupTime.setSeconds(0, 0); // truncate to minute

        const plan = await this.forecastModel.findOne({ time: lookupTime }).exec();

        let alert = false;
        let message = 'Normal';

        if (plan) {
            const threshold = plan.spike_threshold;

            if (power > threshold) {
                alert = true;
                message = `SPIKE DETECTED! ${power}W > ${threshold.toFixed(2)}W`;

                await this.alertModel.create({
                    timestamp,
                    appliance_id: data.appliance_id,
                    power,
                    threshold,
                    message,
                });
                console.log(message);
            }
        } else {
            message = 'No forecast found for this time (Cold Start)';
        }

        return {
            status: 'success',
            spike_detected: alert,
            message,
        };
    }

    async getRecentAlerts() {
        const oneHourAgo = new Date();
        oneHourAgo.setHours(oneHourAgo.getHours() - 1);

        const alerts = await this.alertModel
            .find({ timestamp: { $gte: oneHourAgo } })
            .sort({ timestamp: -1 })
            .exec();

        return {
            count: alerts.length,
            alerts,
        };
    }

    async getRecentReadings(filter?: string) {
        const now = new Date();
        let startTime = new Date();
        let groupFormat = '';

        switch (filter) {
            case 'daily':
                startTime.setDate(now.getDate() - 30); // Last 30 days
                groupFormat = '%Y-%m-%d';
                break;
            case 'hourly':
                startTime.setHours(now.getHours() - 24); // Last 24 hours
                groupFormat = '%Y-%m-%d %H:00';
                break;
            case '60m':
            default:
                startTime.setHours(now.getHours() - 1); // Last 60 minutes
                groupFormat = '%Y-%m-%d %H:%M';
                break;
        }

        const pipeline = [
            {
                $match: {
                    timestamp: { $gte: startTime }
                }
            },
            {
                $group: {
                    _id: { $dateToString: { format: groupFormat, date: "$timestamp" } },
                    power: { $max: "$power" } // Request was: "maximum electricity of each"
                }
            },
            {
                $sort: { _id: 1 as const }
            },
            {
                $project: {
                    _id: 0,
                    timestamp: "$_id",
                    power: 1
                }
            }
        ];

        const aggregatedReadings = await this.readingModel.aggregate(pipeline).exec();

        return {
            count: aggregatedReadings.length,
            readings: aggregatedReadings,
        };
    }

    async getForecasts() {
        const oneHourAgo = new Date();
        oneHourAgo.setHours(oneHourAgo.getHours() - 1);

        const forecasts = await this.forecastModel
            .find({ time: { $gte: oneHourAgo } })
            .sort({ time: 1 })
            .exec();

        return {
            count: forecasts.length,
            forecasts,
        };
    }

    async setOffset(factor: number) {
        await this.settingModel.updateOne(
            { key: 'power_offset' },
            { $set: { value: factor } },
            { upsert: true }
        ).exec();

        return {
            status: 'success',
            message: `Power offset set to ${factor}W`,
        };
    }
}
