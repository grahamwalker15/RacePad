//
//  HeadToHeadView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHeadView.h"
#import "RacePadDatabase.h"
#import "HeadToHead.h"

#import "UIConstants.h"
#import "HeadToHead.h"


@implementation HeadToHeadView

@synthesize userOffset;
@synthesize userScale;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseMembers];		
	}
	
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)dealloc
{
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
	userOffset = 0.0;
	userScale = 1.0;
}

- (void) drawHeadToHead
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	HeadToHead *headToHead = [database headToHead];
	
	if ( headToHead )
	{
		[headToHead drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawHeadToHead];	
}

- (void) adjustScale:(float)scale X:(float)x Y:(float)y
{
	if(current_size_.width < 1 || current_size_.height < 1)
		return;
	
	float currentUserPan = userOffset;
	float currentUserScale = userScale;
	float centreX = x / current_size_.width ;
	
	if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
		return;
	
	// Calculate where the centre point is in the untransformed window
	float x_in_window = (centreX - 0.5) / currentUserScale + 0.5 - currentUserPan;
	
	// Now work out the new scale	
	userScale = currentUserScale * scale;
	
	if(userScale < 1.0)
		userScale = 1.0;
	else if(userScale > 12.0)
		userScale = 12.0;
	
	// And set the user pan to put the focus point back where it was on the screen
	userOffset = (centreX - 0.5) /userScale - x_in_window + 0.5;
	
	if(userOffset > (0.5 - 0.5 / userScale))
		userOffset = (0.5 - 0.5 / userScale);
	else if(userOffset < (0.5 / userScale - 0.5))
		userOffset = (0.5 / userScale - 0.5);
	
}

- (void) adjustPanX:(float)x Y:(float)y
{
	if(current_size_.width < 1 || current_size_.height < 1 || userScale < 1.0)
		return;
	
	userOffset = (userOffset * userScale * current_size_.width + x) / (current_size_.width * userScale);
	
	if(userOffset > (0.5 - 0.5 / userScale))
		userOffset = (0.5 - 0.5 / userScale);
	else if(userOffset < (0.5 / userScale - 0.5))
		userOffset = (0.5 / userScale - 0.5);
}

- (float) transformX:(float)x
{
	return (x - 0.5 + userOffset) * userScale + 0.5;
}

@end

