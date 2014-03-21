//
//  PitchView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PositionsView.h"
#import "BackgroundView.h"
#import "MatchPadDatabase.h"
#import "Positions.h"


@implementation PositionsView

@synthesize isZoomView;
@synthesize isOverlayView;
@synthesize smallSized;
@synthesize homeXOffset;
@synthesize homeYOffset;
@synthesize homeScaleX;
@synthesize homeScaleY;
@synthesize userXOffset;
@synthesize userYOffset;
@synthesize userScale;
@synthesize isAnimating;
@synthesize animationScaleTarget;
@synthesize animationAlpha;
@synthesize animationDirection;
@synthesize autoRotate;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
		[self InitialiseMembers];		
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self InitialiseImages];
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
	userScale = 1.0;
	userXOffset = 0.0;
	userYOffset = 0.0;	
	
	isZoomView = false;
	isOverlayView = false;
	smallSized = false;
	
	isAnimating = false;
	animationDirection = 0;
	animationAlpha = 0.0;
	
	autoRotate = false;
}

- (void)InitialiseImages
{
}

- (float) interpolatedUserScale
{
	if(isAnimating)
		return ((1.0 - animationAlpha) * userScale + animationAlpha * animationScaleTarget);
	else
		return userScale;
}

- (void) drawPositions
{
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	Positions *positions = [database positions];
	
	if ( positions )
	{		
		[positions drawInView:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawPositions];	
}

@end


