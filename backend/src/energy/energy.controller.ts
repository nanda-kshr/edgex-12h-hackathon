import { Controller, Post, Body, Get, Param, ParseIntPipe, Query } from '@nestjs/common';
import { EnergyService } from './energy.service';
import { EnergyReadingDto } from './dto/energy-reading.dto';

@Controller()
export class EnergyController {
    constructor(private readonly energyService: EnergyService) { }

    @Post('ingest')
    async ingestData(@Body() data: EnergyReadingDto) {
        return this.energyService.ingestData(data);
    }

    @Get('alerts/recent')
    async getRecentAlerts() {
        return this.energyService.getRecentAlerts();
    }

    @Get('readings/recent')
    async getRecentReadings(@Query('filter') filter: string) {
        return this.energyService.getRecentReadings(filter);
    }

    @Get('forecast/predictions')
    async getForecasts() {
        return this.energyService.getForecasts();
    }

    @Get('offset/:factor')
    async setOffset(@Param('factor', ParseIntPipe) factor: number) {
        return this.energyService.setOffset(factor);
    }
}
