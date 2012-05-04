//
//  MathOdds.m
//  RacePad
//
//  Created by Gareth Griffith on 1/4/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "TabletState.h"
#import "MathOdds.h"

@implementation TabletState

@synthesize currentRotation;
@synthesize dampedRotation;

static TabletState *instance = nil;

+ (TabletState *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

- (TabletState *) init
{
	if ( [super init] == self )
	{
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDesiredAccuracy: kCLLocationAccuracyBestForNavigation];
	}
	
	return self;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float damper = 0.5f;
	dampedAccelerationX = acceleration.x * damper + (1 - damper) * dampedAccelerationX;
	dampedAccelerationY = acceleration.y * damper + (1 - damper) * dampedAccelerationY;

    currentRotation = RadiansToDegrees ( atan2(acceleration.y, acceleration.x) ) - baseRotation;
    dampedRotation = RadiansToDegrees ( atan2(dampedAccelerationY, dampedAccelerationX) ) - baseRotation;
	
	if ( currentRotation > 180 )
		currentRotation -= 360;
	if ( currentRotation < -180 )
		currentRotation += 360;

	if ( dampedRotation > 180 )
		dampedRotation -= 360;
	if ( dampedRotation < -180 )
		dampedRotation += 360;
	
}

- (void)setBaseRotation:(UIInterfaceOrientation)interfaceOrientation
{
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			baseRotation = -90;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			baseRotation = 90;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			baseRotation = 0;
			break;
		case UIInterfaceOrientationLandscapeRight:
			baseRotation = 180;
			break;
		default:
			break;
	}
}

- (void) startTracking:(id<CLLocationManagerDelegate>)handler TrackType:(unsigned char)trackType
{
	[locationManager setDelegate:handler];
	if ( trackType & TS_LOCATION )
	{
		if ( [CLLocationManager locationServicesEnabled] )
		{
			[locationManager startUpdatingLocation];
		}
	}
	if ( trackType & TS_HEADING && [CLLocationManager headingAvailable] )
	{
		[locationManager startUpdatingHeading];
	}
}

- (void) stopTracking
{
	[locationManager stopUpdatingHeading];
	[locationManager stopUpdatingLocation];
}

- (void) currentPosition:(float *)longitude Lat:(float *)latitude
{
	*longitude = locationManager.location.coordinate.longitude;
	*latitude = locationManager.location.coordinate.latitude;
}

- (void) currentPosition:(double *)longitude Lat:(double *)latitude Accuracy: (double *)radius;
{
	*longitude = locationManager.location.coordinate.longitude;
	*latitude = locationManager.location.coordinate.latitude;
	*radius = locationManager.location.horizontalAccuracy;
}

@end