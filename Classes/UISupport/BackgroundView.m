//
//  BackgroundView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BackgroundView.h"

///////////////////////////////////////////////////////////////////////////////////////
//  Base Class

@implementation BackgroundView

@synthesize style;

static UIImage * screen_bg_image_ = nil;
static UIImage * grey_bg_image_  = nil;
static UIImage * grass_bg_image_ = nil;

static bool bg_images_initialised_ = false;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseImages];
		style = BG_STYLE_FULL_SCREEN_GREY_;
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
 		[self InitialiseImages];
		style = BG_STYLE_FULL_SCREEN_GREY_;
	}
    return self;
}

- (void)dealloc
{	
	[screen_bg_image_ release];
	[grey_bg_image_  release];
	[grass_bg_image_  release];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseImages
{
	if(!bg_images_initialised_)
	{
		bg_images_initialised_ = true;
		
		screen_bg_image_ = [[UIImage imageNamed:@"Parchment.png"] retain];
		grey_bg_image_  = [[UIImage imageNamed:@"Metal.png"] retain];
		grass_bg_image_  = [[UIImage imageNamed:@"Grass.png"] retain];
	}
	else
	{
		[screen_bg_image_ retain];
		[grey_bg_image_  retain];
		[grass_bg_image_  retain];
	}
}


- (void)Draw:(CGRect) rect
{
	// Draw the background
	[self SaveGraphicsState];
	
	switch (style)
	{
		case BG_STYLE_FULL_SCREEN_GREY_:
		{
			[self DrawPattern:screen_bg_image_ InRect:current_bounds_];	
			[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
	
			CGRect inner_rect = CGRectInset(current_bounds_, BG_INSET, BG_INSET);
			[self DrawPattern:grey_bg_image_  InRect:inner_rect];
			break;
		}
		
		case BG_STYLE_FULL_SCREEN_GRASS_:
		{
			[self DrawPattern:screen_bg_image_ InRect:current_bounds_];	
			[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
			
			CGRect inner_rect = CGRectInset(current_bounds_, BG_INSET, BG_INSET);
			[self DrawPattern:grass_bg_image_  InRect:inner_rect];
			break;
		}
	
		case BG_STYLE_TRANSPARENT_:
		{
			[self SetLineWidth:3];
			[self SetFGColour:white_];
			CGRect inner_rect = CGRectInset(current_bounds_, 1, 1);
			[self LineRectangle:inner_rect];
			break;
		}
		
		default:
			break;
	}
		
	[self RestoreGraphicsState];
}

@end
