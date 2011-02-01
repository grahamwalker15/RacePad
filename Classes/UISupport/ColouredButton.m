//
//  ColouredButton.m
//  RacePad
//
//  Created by Gareth Griffith on 1/29/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "ColouredButton.h"


@implementation ColouredButton

@synthesize textColour;
@synthesize buttonColour;
@synthesize outlineColour;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self setDefaultColours];
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
	{
         [self setDefaultColours];
    }
    return self;
}

- (void) setDefaultColours
{
	[self setTextColour:[UIColor darkTextColor]];
	[self setButtonColour:[UIColor whiteColor]];
	[self setOutlineColour:[UIColor blackColor]];
}

- (void) setTextColour:(UIColor *)colour
{
	UIColor * oldTextColour = textColour;
	textColour = [colour retain];
	[oldTextColour release];
	
	[self setTitleColor:textColour forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect
{
	// Create rounded path filling the bounds
	CGRect bounds = [self bounds];
	
	float x0 = bounds.origin.x + 1;
	float y0 = bounds.origin.y + 1;
	float x1 = x0 + bounds.size.width - 2;
	float y1 = y0 + bounds.size.height - 2;
	
	float r = 10.0;
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	if(r > (x1 - x0) * 0.4)
		r = (x1 - x0) * 0.4;
	
	if(r > (y1 - y0) * 0.4)
		r = (y1 - y0) * 0.4;
	
	CGPathMoveToPoint (path, nil, x0, (y0 + r));
	CGPathAddLineToPoint (path, nil, x0, (y1 - r));
	CGPathAddArcToPoint (path, nil, x0, y1, x0 + r, y1, r);
	CGPathAddLineToPoint (path, nil, (x1 - r), y1);
	CGPathAddArcToPoint (path, nil, x1, y1, x1, (y1 - r), r);
	CGPathAddLineToPoint (path, nil, x1, (y0 + r));
	CGPathAddArcToPoint (path, nil, x1, y0, (x1 - r), y0, r);
	CGPathAddLineToPoint (path, nil, (x0 + r), y0);
	CGPathAddArcToPoint (path, nil, x0, y0, x0, (y0 + r), r);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState (context);
	CGContextBeginPath (context);
	CGContextAddPath(context, path);
	CGContextClip (context);
	[buttonColour set];
	CGContextFillRect(context, bounds);
	CGContextRestoreGState (context);
		
	//CGContextBeginPath (context);
	//CGContextAddPath(context, path);
	//[outlineColour set];
	//CGContextStrokePath (context);

	CGPathRelease(path);
}

- (void)requestRedraw
{
	[self setNeedsDisplay];
	[[self titleLabel] setNeedsDisplay];
}

- (void)dealloc
{
	[textColour release];
	[buttonColour release];
	[outlineColour release];
    [super dealloc];
}


@end
