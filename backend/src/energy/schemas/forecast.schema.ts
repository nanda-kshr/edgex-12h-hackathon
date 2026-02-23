import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ForecastDocument = Forecast & Document;

@Schema({ collection: 'forecasts' })
export class Forecast {
    @Prop({ required: true })
    time: Date;

    @Prop({ required: true })
    spike_threshold: number;

    @Prop()
    expected_power?: number;
}

export const ForecastSchema = SchemaFactory.createForClass(Forecast);
