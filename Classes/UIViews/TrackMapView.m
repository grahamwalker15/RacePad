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
	[super layoutSubviews];
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
		
		background_image_ = nil;
		background_image_w_ = 0;
		background_image_h_ = 0;
	}
}

- (void)CheckBackground
{
	int current_width = current_size_.width;
	int current_height = current_size_.height;
	
	if(!background_image_ || background_image_w_ != current_width || background_image_h_ != current_height)
	{
		// Free any existing image
		if(background_image_)
		{
			CGImageRelease(background_image_);
			background_image_ = nil;
			background_image_w_ = 0;
			background_image_h_ = 0;
		}
		
		// Make a new image context
		if([self CreateBitmapContext])
		{
			// Draw the background
			[self SaveGraphicsState];
			
			[self DrawPattern:screen_bg_image_ InRect:current_bounds_];	
			[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
			
			CGRect map_rect = CGRectInset(current_bounds_, 30, 30);
			[self DrawPattern:map_bg_image_ InRect:map_rect];	
			
			[self RestoreGraphicsState];
			
			// Get the background image from the bitmap context
			background_image_ = [self GetImageFromBitmapContext];
			background_image_w_ = current_width;
			background_image_h_ = current_height;
			
			// Restore the old context
			[self DestroyBitmapContext];
		}
	}
}

- (void)ReleaseBackground
{
	if(background_image_)
	{
		CGImageRelease(background_image_);
		background_image_ = nil;
	}
			
	background_image_w_ = 0;
	background_image_h_ = 0;
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
	
	[self ClearScreen];
	
	[self CheckBackground];
	
	if(background_image_)
		CGContextDrawImage (current_context_, current_bounds_, background_image_);
	
	[self drawTrack];
	
}

@end

