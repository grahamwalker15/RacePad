//
//  HeadToHeadView.h
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface HeadToHeadView : DrawingView
{
	float userOffsetX;
	float userScaleX;
	float userOffsetY;
	float userScaleY;
}

@property (nonatomic) float userOffsetX;
@property (nonatomic) float userScaleX;
@property (nonatomic) float userOffsetY;
@property (nonatomic) float userScaleY;

- (void)InitialiseMembers;

- (void) adjustScaleX:(float)scale X:(float)x Y:(float)y;
- (void) adjustScaleY:(float)scale X:(float)x Y:(float)y;
- (void) adjustPanX:(float)x;
- (void) adjustPanY:(float)y;
- (float) transformX:(float)x;
- (float) transformY:(float)y;
- (float) yOffset;

@end

