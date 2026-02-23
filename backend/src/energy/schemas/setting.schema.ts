import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type SettingDocument = Setting & Document;

@Schema({ collection: 'settings' })
export class Setting {
    @Prop({ required: true, unique: true })
    key: string;

    @Prop({ type: Object })
    value: any;
}

export const SettingSchema = SchemaFactory.createForClass(Setting);
