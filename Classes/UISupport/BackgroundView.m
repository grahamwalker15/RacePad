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
@synthesize inset;

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
		inset = 0;

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
		inset = 0;

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
		
		screen_bg_image_ = [[UIImage imageNamed:@"GraphPaper.png"] retain];
		grey_bg_image_  = [[UIImage imageNamed:@"CarbonFibre2.png"] retain];
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
			inset = 0;
			[self DrawPattern:grey_bg_image_ InRect:current_bounds_];	
			break;
		}
		
		case BG_STYLE_FULL_SCREEN_GRASS_:
		{
			inset = 20;
			
			[self DrawPattern:screen_bg_image_ InRect:current_bounds_];	
			[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
			
			CGRect inner_rect = CGRectInset(current_bounds_, inset, inset);
			[self DrawPattern:grass_bg_image_  InRect:inner_rect];
			break;
		}
	
		case BG_STYLE_TRANSPARENT_:
		{
			inset = 0;
			
			[self SetLineWidth:3];
			[self SetFGColour:white_];
			CGRect inner_rect = CGRectInset(current_bounds_, 1, 1);
			[self LineRectangle:inner_rect];
			break;
		}
		
		case BG_STYLE_SHADOWED_GREY_:
		{
			inset = 20;
			
			[self DrawPattern:screen_bg_image_ InRect:current_bounds_];	
			[self SetDropShadowXOffset:10.0 YOffset:10.0 Blur:5.0];
			
			CGRect inner_rect = CGRectInset(current_bounds_, inset, inset);
			[self DrawPattern:grey_bg_image_  InRect:inner_rect];
			break;
		}
			
		default:
			break;
	}
		
	[self RestoreGraphicsState];

}


@end
