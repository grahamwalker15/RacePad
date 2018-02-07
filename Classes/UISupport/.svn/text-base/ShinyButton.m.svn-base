//
//  ShinyButton.m
//  RacePad
//
//  Created by Gareth Griffith on 2/2/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "ShinyButton.h"


@implementation ShinyButton

@synthesize shine;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		shine = 0.3;
	}
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self)
	{
		shine = 0.3;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	// Make highlight colour and shadow colour from button colour
	
	UIColor * baseColour;
	if([self isSelected])
		baseColour = [selectedButtonColour retain];
	else
		baseColour = [buttonColour retain];
	
	int component_count = CGColorGetNumberOfComponents ([baseColour CGColor]);
	const CGFloat *components = CGColorGetComponents([baseColour CGColor]);
	
	CGFloat r, g, b;
	
	if(component_count < 3)
	{
		r = components[0];
		g = components[0];
		b = components[0];
	}
	else
	{
		r = components[0];
		g = components[1];
		b = components[2];
	}
		
	// If the button is white, darken it a bit
	if(r > 0.95 && g > 0.95 && b > 0.95)
	{
		r = 0.95;
		g = 0.95;
		b = 0.95;
		
		[baseColour release];
		baseColour = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1.0];
	}
	
	// Now make the highlight and shadow

	CGFloat rh = r * 1.2; if(rh > 1.0) rh = 1.0;
	CGFloat gh = g * 1.2; if(gh > 1.0) gh = 1.0;
	CGFloat bh = b * 1.2; if(bh > 1.0) bh = 1.0;
	UIColor * highlight = [[UIColor alloc] initWithRed:rh green:gh blue:bh alpha:1.0];
	
	CGFloat rs = r * 0.5;
	CGFloat gs = g * 0.5;
	CGFloat bs = b * 0.5;
	UIColor * shadow = [[UIColor alloc] initWithRed:rs green:gs blue:bs alpha:1.0];
	
	CGFloat rw = r + shine; if(rw > 1.0) rw = 1.0;
	CGFloat gw = g + shine; if(gw > 1.0) gw = 1.0;
	CGFloat bw = b + shine; if(bw > 1.0) bw = 1.0;
	UIColor * white = [[UIColor alloc] initWithRed:rw green:gw blue:bw alpha:1.0];

	// Create rounded path filling the bounds
	// Create rounded path filling the bounds
	CGRect bounds = [self bounds];
	
	if(outline)
		bounds = CGRectInset(bounds, 2, 2);
	
	float x0 = bounds.origin.x + 0.5;
	float y0 = bounds.origin.y + 0.5;
	float x1 = x0 + bounds.size.width - 1.0 ;
	float y1 = y0 + bounds.size.height - 1.0;
	
	float rad = radius;
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	if(rad > (x1 - x0) * 0.4)
		rad = (x1 - x0) * 0.4;
	
	if(rad > (y1 - y0) * 0.4)
		rad = (y1 - y0) * 0.4;
	
	CGPathMoveToPoint (path, nil, x0, (y0 + rad));
	CGPathAddLineToPoint (path, nil, x0, (y1 - rad));
	CGPathAddArcToPoint (path, nil, x0, y1, x0 + rad, y1, rad);
	CGPathAddLineToPoint (path, nil, (x1 - rad), y1);
	CGPathAddArcToPoint (path, nil, x1, y1, x1, (y1 - rad), rad);
	CGPathAddLineToPoint (path, nil, x1, (y0 + rad));
	CGPathAddArcToPoint (path, nil, x1, y0, (x1 - rad), y0, rad);
	CGPathAddLineToPoint (path, nil, (x0 + rad), y0);
	CGPathAddArcToPoint (path, nil, x0, y0, x0, (y0 + rad), rad);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState (context);
	CGContextBeginPath (context);
	CGContextAddPath(context, path);
	CGContextClip (context);
	
	// Vertical gradient based on current background colour
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGColorRef colors[] = {[shadow CGColor], [highlight CGColor], [white CGColor], [highlight CGColor], [baseColour CGColor], [shadow CGColor]};
	CFArrayRef colorsArray = CFArrayCreate(NULL, (void *)colors, 6, &kCFTypeArrayCallBacks);
	
	CGFloat locations[] = {0.0, 0.1, 0.3, 0.4, 0.6, 1.0};
	
	CGGradientRef gradient = CGGradientCreateWithColors(colorspace, colorsArray, locations);
	
	CFRelease(colorsArray);
	CGColorSpaceRelease(colorspace);
	
	CGPoint start_point = bounds.origin;
	CGPoint end_point = CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height);
	CGContextDrawLinearGradient(context, gradient, start_point, end_point, 0);
	
	CGGradientRelease(gradient);
	
	[highlight release];
	[shadow release];
	[white release];
	
	CGContextRestoreGState (context);
	
	if(outline)
	{
		CGContextBeginPath (context);
		CGContextAddPath(context, path);
		
		[outlineColour set];
		CGContextStrokePath (context);
	}
	
	CGPathRelease(path);
	
	[baseColour release];
}

@end
