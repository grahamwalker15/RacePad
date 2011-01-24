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
    currentRotation = RadiansToDegrees ( atan2(acceleration.y, acceleration.x) );
}

@end