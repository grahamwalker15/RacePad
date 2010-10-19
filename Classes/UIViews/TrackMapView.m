//
//  TrackMapView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapView.h"
#import "RacePadDatabase.h"
#import "TrackMap.h"


@implementation TrackMapView

static UIImage * screen_bg_image_ = nil;
static UIImage * map_bg_image_ = nil;

static bool images_initialised_ = false;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		// Put any class specific initialisation here
    }
    return self;
}

- (void)layoutSubviews
{
}

- (void)dealloc
{
	[screen_bg_image_ release];
	[map_bg_image_ release];
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 


- (void)InitialiseImages
{
	if(!images_initialised_)
	{
		images_initialised_ = true;
		
		screen_bg_image_ = [[UIImage imageNamed:@"Parchment.png"] retain];
		map_bg_image_ = [[UIImage imageNamed:@"Metal.png"] retain];
	}
}

- (void) drawTrack
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	if ( trackMap )
	{
		[trackMap draw:self];
	}
}

- (void)Draw:(CGRect) rect
{
	[self SetBGColour:[UIColor colorWithRed:0.00 green:0.0 blue:0.0 alpha:1.0]];
	
	[self SaveGraphicsState];
	[self DrawPattern:screen_bg_image_ InRect:current_bounds_];
	
	[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
	CGRect map_rect = CGRectInset(current_bounds_, 30, 30);
	[self DrawPattern:map_bg_image_ InRect:map_rect];
	
	[self SetDropShadowXOffset:5.0 YOffset:5.0 Blur:3.0];

	[self drawTrack];
	
	[self RestoreGraphicsState];
}

@end

