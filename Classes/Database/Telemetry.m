//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Telemetry.h"
#import "DataStream.h"
// #import "TelemetryView.h"

@implementation TelemetryCar

- (void) load:(DataStream *)stream 
{
	speed = [stream PopFloat];
	throttle = [stream PopFloat];
	distance = [stream PopFloat];
	gLong = [stream PopFloat];
	gLat = [stream PopFloat];
	brake = [stream PopFloat];
	steering = [stream PopFloat];
	laps = [stream PopInt];
}

- (void) draw:(TelemetryView *)view
{
}

@end


@implementation Telemetry

- (id) init
{
	if(self = [super init])
	{
		redCar = [[TelemetryCar alloc] init];
		blueCar = [[TelemetryCar alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[redCar release];
	[blueCar release];
	
	[super dealloc];
}

- (void) load : (DataStream *) stream
{
	[redCar load:stream];
	[blueCar load:stream];
}

- (void) drawInView:(TelemetryView *)view
{	
}


////////////////////////////////////////////////////////////////////////
//


@end

