import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type AlertDocument = Alert & Document;

@Schema({ collection: 'alerts' })
export class Alert {
    @Prop({ required: true })
    timestamp: Date;

    @Prop({ required: true })
    appliance_id: string;

    @Prop({ required: true })
    power: number;

    @Prop({ required: true })
    threshold: number;

    @Prop({ required: true })
    message: string;
}

export const AlertSchema = SchemaFactory.createForClass(Alert);
