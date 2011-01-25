//
//  TabletState.h
//  RacePad
//
//  Created by Mark Riches on 24/1/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

@interface TabletState : NSObject <UIAccelerometerDelegate>
{
	
	float currentRotation;
	float baseRotation;
	float dampedRotation;
	float dampedAccelerationX;
	float dampedAccelerationY;
		
}

@property (readonly) float currentRotation;
@property (readonly) float dampedRotation;

+ (TabletState *)Instance;
- (void) setBaseRotation: (UIInterfaceOrientation)interfaceOrientation;

@end

