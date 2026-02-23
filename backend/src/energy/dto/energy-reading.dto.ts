import { IsString, IsNumber, IsOptional, IsDateString } from 'class-validator';

export class EnergyReadingDto {
  @IsString()
  appliance_id: string;

  @IsNumber()
  power: number;

  @IsOptional()
  @IsDateString()
  timestamp?: string | Date;
}
