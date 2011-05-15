//
//  TrackProfileView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackProfileView.h"
#import "BackgroundView.h"
#import "RacePadDatabase.h"
#import "TrackProfile.h"


@implementation TrackProfileView

@synthesize userOffset;
@synthesize userScale;
@synthesize carToFollow;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseMembers];		
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
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
	[carToFollow release];
	carToFollow = nil;
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseMembers
{
	carToFollow = nil;
	userOffset = 0.0;
	userScale = 1.0;
}

- (void) followCar:(NSString *)name
{
	if(name && [name length] > 0)
	{
		if(![carToFollow isEqualToString:name])
		{
			[carToFollow release];
			carToFollow = [name retain];
			return;
		}
		else
		{
			return;
		}

	}
	
	// Reach here if either name was nil, or not found
	[carToFollow release];
	carToFollow = nil;	
}

- (void) drawTrack
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackProfile *trackProfile = [database trackProfile];
	
	if ( trackProfile )
	{		
		[trackProfile drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawTrack];	
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


