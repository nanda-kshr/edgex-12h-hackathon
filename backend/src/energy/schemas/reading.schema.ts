import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ReadingDocument = Reading & Document;

@Schema({ collection: 'readings' })
export class Reading {
    @Prop({ required: true })
    appliance_id: string;

    @Prop({ required: true })
    power: number;

    @Prop({ required: true })
    timestamp: Date;
}

export const ReadingSchema = SchemaFactory.createForClass(Reading);
