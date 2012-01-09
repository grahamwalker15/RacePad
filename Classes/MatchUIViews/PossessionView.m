//
//  PossessionView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PossessionView.h"
#import "MatchPadDatabase.h"
#import "Possession.h"

#import "UIConstants.h"

@implementation PossessionView

@synthesize userOffsetX;
@synthesize userScaleX;
@synthesize userOffsetY;
@synthesize userScaleY;

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
	userOffsetX = 0.0;
	userScaleX = 1.0;
	userOffsetY = 0.0;
	userScaleY = 1.0;
}

- (void) drawPossession
{
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	Possession *possession = [database possession];
	
	if ( possession )
	{
		[possession drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawPossession];	
}

- (void) adjustScaleX:(float)scale X:(float)x Y:(float)y
{
	if(current_size_.width < 1 || current_size_.height < 1)
		return;
	
	float currentUserPan = userOffsetX;
	float currentUserScale = userScaleX;
	float centreX = x / current_size_.width ;
	
	if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
		return;
	
	// Calculate where the centre point is in the untransformed window
	float x_in_window = (centreX - 0.5) / currentUserScale + 0.5 - currentUserPan;
	
	// Now work out the new scale	
	userScaleX = currentUserScale * scale;
	
	if(userScaleX < 1.0)
		userScaleX = 1.0;
	else if(userScaleX > 12.0)
		userScaleX = 12.0;
	
	// And set the user pan to put the focus point back where it was on the screen
	userOffsetX = (centreX - 0.5) /userScaleX - x_in_window + 0.5;
	
	if(userOffsetX > (0.5 - 0.5 / userScaleX))
		userOffsetX = (0.5 - 0.5 / userScaleX);
	else if(userOffsetX < (0.5 / userScaleX - 0.5))
		userOffsetX = (0.5 / userScaleX - 0.5);
	
}

- (void) adjustScaleY:(float)scale X:(float)x Y:(float)y
{
	// Do nothing for the moment
	return;
	
	if(current_size_.width < 1 || current_size_.height < 1)
		return;
	
	float currentUserPan = userOffsetY;
	float currentUserScale = userScaleY;
	float centreY = y / current_size_.height ;
	
	if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
		return;
	
	// Calculate where the centre point is in the untransformed window
	float y_in_window = (centreY - 0.5) / currentUserScale + 0.5 - currentUserPan;
	
	// Now work out the new scale	
	userScaleY = currentUserScale * scale;
	
	if(userScaleY < 1.0)
		userScaleY = 1.0;
	else if(userScaleY > 12.0)
		userScaleY = 12.0;
	
	// And set the user pan to put the focus point back where it was on the screen
	userOffsetY = (centreY - 0.5) /userScaleY - y_in_window + 0.5;
	
	if(userOffsetY > (0.5 - 0.5 / userScaleY))
		userOffsetY = (0.5 - 0.5 / userScaleY);
	else if(userOffsetY < (0.5 / userScaleY - 0.5))
		userOffsetY = (0.5 / userScaleY - 0.5);
	
}

- (void) adjustPanX:(float)x
{
	if(current_size_.width < 1 || current_size_.height < 1 || userScaleX < 1.0)
		return;
	
	userOffsetX = (userOffsetX * userScaleX * current_size_.width + x) / (current_size_.width * userScaleX);
	
	if(userOffsetX > (0.5 - 0.5 / userScaleX))
		userOffsetX = (0.5 - 0.5 / userScaleX);
	else if(userOffsetX < (0.5 / userScaleX - 0.5))
		userOffsetX = (0.5 / userScaleX - 0.5);
}

- (void) adjustPanY:(float)y
{
	// Simplify for the moment
	 
	if(current_size_.width < 1 || current_size_.height < 1 || userScaleY < 1.0)
		return;
	
	userOffsetY += (y / current_size_.height);
	
	if(userOffsetY > 0.5)
		userOffsetY = 0.5;
	else if(userOffsetY < -0.5)
		userOffsetY = -0.5;

	/*
	userOffsetY = (userOffsetY * userScaleY * current_size_.width + y) / (current_size_.width * userScaleY);
	
	if(userOffsetY > (0.5 - 0.5 / userScaleY))
		userOffsetY = (0.5 - 0.5 / userScaleY);
	else if(userOffsetY < (0.5 / userScaleY - 0.5))
		userOffsetY = (0.5 / userScaleY - 0.5);
	*/
}

- (float) transformX:(float)x
{
	return (x - 0.5 + userOffsetX) * userScaleX + 0.5;
}

- (float) transformY:(float)y
{
	//return (y - 0.5 + userOffsetY) * userScaleY + 0.5;
	return y * userScaleY;
}

- (float) yOffset
{
	return 	userOffsetY * current_size_.height;
}

@end

