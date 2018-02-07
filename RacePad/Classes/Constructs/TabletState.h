//
//  TabletState.h
//  RacePad
//
//  Created by Mark Riches on 24/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <math.h>

enum TrackType {
	TS_LOCATION = 1,
	TS_HEADING = 2
};

@interface TabletState : NSObject <UIAccelerometerDelegate>
{
	
	float currentRotation;
	float baseRotation;
	float dampedRotation;
	float dampedAccelerationX;
	float dampedAccelerationY;
		
	CLLocationManager *locationManager;
	
}

@property (readonly) float currentRotation;
@property (readonly) float dampedRotation;

+ (TabletState *)Instance;
- (void) setBaseRotation: (UIInterfaceOrientation)interfaceOrientation;

- (void) startTracking: (id<CLLocationManagerDelegate>) handler TrackType: (unsigned char)trackType;
- (void) stopTracking;

- (void) currentPosition: (float *)longitude Lat: (float *) latitude;
- (void) currentPosition: (double *)longitude Lat: (double_t *) latitude Accuracy: (double *)radius;

@end

