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
static UIImage * carbon_bg_image_  = nil;
static UIImage * grey_bg_image_  = nil;
static UIImage * grass_bg_image_ = nil;
static UIImage * midas_bg_image_ = nil;

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
		style = BG_STYLE_FULL_SCREEN_CARBON_;
		inset = 0;
		
		frames = [[NSMutableArray alloc] init];
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
 		[self InitialiseImages];
		style = BG_STYLE_FULL_SCREEN_CARBON_;
		inset = 0;

		frames = [[NSMutableArray alloc] init];
	}
    return self;
}

- (void)dealloc
{	
	[screen_bg_image_ release];
	[carbon_bg_image_  release];
	[grey_bg_image_  release];
	[grass_bg_image_  release];
	[midas_bg_image_  release];
	
	[frames removeAllObjects];
	[frames release];
	
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
		grey_bg_image_  = [[UIImage imageNamed:@"GreyTextureBG.png"] retain];
		carbon_bg_image_  = [[UIImage imageNamed:@"CarbonFibre2.png"] retain];
		grass_bg_image_  = [[UIImage imageNamed:@"Grass.png"] retain];
		midas_bg_image_  = [[UIImage imageNamed:@"midas_background.png"] retain];
	}
	else
	{
		[screen_bg_image_ retain];
		[grey_bg_image_  retain];
		[carbon_bg_image_  retain];
		[grass_bg_image_  retain];
		[midas_bg_image_  retain];
	}
}


- (void)Draw:(CGRect) rect
{
	// Draw the background
	[self SaveGraphicsState];
	
	switch (style)
	{
		case BG_STYLE_FULL_SCREEN_CARBON_:
		{
			inset = 0;
			[self DrawPattern:carbon_bg_image_ InRect:current_bounds_];	
			break;
		}
			
		case BG_STYLE_MIDAS_:
		{
			inset = 0;
			[self DrawPattern:midas_bg_image_ InRect:current_bounds_];	
			break;
		}
			
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
			
		case BG_STYLE_INVISIBLE_:
		{
			inset = 0;
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
			
		case BG_STYLE_ROUNDED_STRAP_:
		{
			CGMutablePathRef rect = [DrawingView CreateRoundedRectPathX0:current_bounds_.origin.x Y0:current_bounds_.origin.x X1:current_bounds_.size.width Y1:current_bounds_.size.height Radius:10.0];
			
			[self SetBGColour: [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
			[self FillPath:rect];
			
			CGPathRelease(rect);
		}
			
		default:
			break;
	}
		
	[self RestoreGraphicsState];
	
	[self drawFrames];

}

- (void)drawFrames
{
	for (int i = 0 ; i < [frames count] ; i++)
	{
		CGRect rect = [(NSValue *)[frames objectAtIndex:i] CGRectValue];
		[self drawOutline:rect];
	}
}

- (void)clearFrames
{
	[frames removeAllObjects];
}

- (void)addFrame:(CGRect) rect
{
	[frames addObject:[NSValue valueWithCGRect:rect]];
}

- (void)drawOutline:(CGRect) rect
{
	// Draw outline outside given rect
	[self SaveGraphicsState];
	[self SetLineWidth:2];
	[self SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	CGRect draw_rect = CGRectInset(rect, -4, -4);
	[self LineRectangle:draw_rect];
	[self SetFGColour:[self black_]];
	draw_rect = CGRectInset(rect, -2, -2);
	[self LineRectangle:draw_rect];
	[self RestoreGraphicsState];
}


@end
