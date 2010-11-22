//
//  Telemetry.h
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class TelemetryView;

@interface TelemetryCar : NSObject
{
	float speed;
	float throttle;
	float distance;
	float gLong;
	float gLat;
	float brake;
	float steering;
	int laps;
}

- (void) load : (DataStream *) stream;
- (void) draw:(TelemetryView *)view;

@end

@interface Telemetry : NSObject
{
	
	TelemetryCar *redCar;
	TelemetryCar *blueCar;
}

- (void) load : (DataStream *) stream;
- (void) drawInView:(TelemetryView *)view;

@end
