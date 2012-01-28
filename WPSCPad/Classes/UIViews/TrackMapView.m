//
//  TrackMapView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapView.h"
#import "BackgroundView.h"
#import "RacePadDatabase.h"
#import "TrackMap.h"


@implementation TrackMapView

@synthesize isZoomView;
@synthesize isOverlayView;
@synthesize smallSized;
@synthesize midasStyle;

@synthesize homeXOffset;
@synthesize homeYOffset;
@synthesize homeScale;
@synthesize userXOffset;
@synthesize userYOffset;
@synthesize userScale;
@synthesize carToFollow;
@synthesize isAnimating;
@synthesize animationScaleTarget;
@synthesize animationAlpha;
@synthesize animationDirection;
@synthesize autoRotate;

static UIImage * greenFlagImage = nil;
static UIImage * yellowFlagImage = nil;
static UIImage * redFlagImage = nil;
static UIImage * chequeredFlagImage = nil;
static UIImage * scFlagImage = nil;
static UIImage * scinFlagImage = nil;

static bool flag_images_initialised_ = false;

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
	[carToFollow release];
	carToFollow = nil;

	[greenFlagImage release];
	[yellowFlagImage release];
	[redFlagImage release];
	[chequeredFlagImage release];
	[scFlagImage release];
	[scinFlagImage release];
	
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
	
	midasStyle = false;
	
	isAnimating = false;
	animationDirection = 0;
	animationAlpha = 0.0;
	
	carToFollow = nil;
	autoRotate = false;
}

- (void)InitialiseImages
{
	if(!flag_images_initialised_)
	{
		flag_images_initialised_ = true;
		
		greenFlagImage = [[UIImage imageNamed:@"StateGreen.png"] retain];
		yellowFlagImage = [[UIImage imageNamed:@"StateYellow.png"] retain];
		redFlagImage = [[UIImage imageNamed:@"StateRed.png"] retain];
		chequeredFlagImage = [[UIImage imageNamed:@"StateChequered.png"] retain];
		scFlagImage = [[UIImage imageNamed:@"StateSC.png"] retain];
		scinFlagImage = [[UIImage imageNamed:@"StateSCIn.png"] retain];
	}
	else
	{
		[greenFlagImage retain];
		[yellowFlagImage retain];
		[redFlagImage retain];
		[chequeredFlagImage retain];
		[scFlagImage retain];
		[scinFlagImage retain];
	}

}

- (float) interpolatedUserScale
{
	if(isAnimating)
		return ((1.0 - animationAlpha) * userScale + animationAlpha * animationScaleTarget);
	else
		return userScale;
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
	TrackMap *trackMap = [database trackMap];
	
	if ( trackMap )
	{		
		[trackMap drawInView:self];

		if(!isZoomView && !smallSized)
		{
			int track_state = [trackMap getTrackState];
			
			CGPoint flagPos = CGPointMake(current_origin_.x + current_size_.width - 130, current_origin_.y + 10);
			if(track_state == TM_TRACK_YELLOW)
				[yellowFlagImage drawAtPoint:flagPos];
			else if(track_state == TM_TRACK_RED)
				[redFlagImage drawAtPoint:flagPos];
			else if(track_state == TM_TRACK_CHEQUERED)
				[chequeredFlagImage drawAtPoint:flagPos];
			else if(track_state == TM_TRACK_SC)
				[scFlagImage drawAtPoint:flagPos];
			else if(track_state == TM_TRACK_SCIN)
				[scinFlagImage drawAtPoint:flagPos];
		}
	}
}

- (void)Draw:(CGRect) rect
{
	[self ClearScreen];
	[self drawTrack];	
}

@end


