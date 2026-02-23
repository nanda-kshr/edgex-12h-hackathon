import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { EnergyController } from './energy.controller';
import { EnergyService } from './energy.service';
import { Reading, ReadingSchema } from './schemas/reading.schema';
import { Alert, AlertSchema } from './schemas/alert.schema';
import { Setting, SettingSchema } from './schemas/setting.schema';
import { Forecast, ForecastSchema } from './schemas/forecast.schema';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Reading.name, schema: ReadingSchema },
            { name: Alert.name, schema: AlertSchema },
            { name: Setting.name, schema: SettingSchema },
            { name: Forecast.name, schema: ForecastSchema },
        ]),
    ],
    controllers: [EnergyController],
    providers: [EnergyService],
})
export class EnergyModule { }
