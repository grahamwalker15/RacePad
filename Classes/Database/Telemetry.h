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
	int gear;
	int rpm;
}

- (void) load : (DataStream *) stream;
- (void) drawInView:(TelemetryView *)view Colour:(int)colour;

@end

@interface Telemetry : NSObject
{
	
	TelemetryCar *redCar;
	TelemetryCar *blueCar;
}

@property (readonly) TelemetryCar *redCar;
@property (readonly) TelemetryCar *blueCar;

- (void) load : (DataStream *) stream;
- (void) drawCar:(int)car InView:(TelemetryView *)view;

@end
