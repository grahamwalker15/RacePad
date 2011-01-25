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

static TabletState *instance = nil;

+ (TabletState *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    currentRotation = RadiansToDegrees ( atan2(acceleration.y, acceleration.x) ) - baseRotation;
	
	if ( currentRotation > 180 )
		currentRotation -= 360;
	if ( currentRotation < -180 )
		currentRotation += 360;
	
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


@end