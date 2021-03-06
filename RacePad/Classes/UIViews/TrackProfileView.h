//
//  TrackProfileView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface TrackProfileView : DrawingView
{
	float userOffset;
	float userScale;

	NSString * carToFollow;
}

@property (nonatomic) float userOffset;
@property (nonatomic) float userScale;
@property (nonatomic, retain) NSString * carToFollow;

- (void)InitialiseMembers;
- (void)followCar:(NSString *)name;

- (void) adjustScale:(float)scale X:(float)x Y:(float)y;
- (void) adjustPanX:(float)x Y:(float)y;
- (float) transformX:(float)x;

@end

