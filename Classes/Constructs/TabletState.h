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
		
}

@property (readonly) float currentRotation;

+ (TabletState *)Instance;
- (void) setBaseRotation: (UIInterfaceOrientation)interfaceOrientation;

@end

