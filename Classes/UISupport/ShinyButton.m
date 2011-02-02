//
//  ShinyButton.m
//  RacePad
//
//  Created by Gareth Griffith on 2/2/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "ShinyButton.h"


@implementation ShinyButton


- (void)drawRect:(CGRect)rect
{
	// Make highlight colour and shadow colour from button colour
	
	UIColor * highlight;
	UIColor * shadow;
	
	int component_count = CGColorGetNumberOfComponents ([buttonColour CGColor]);
	const CGFloat *components = CGColorGetComponents([buttonColour CGColor]);
	
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
		r = 0.8;
		g = 0.8;
		b = 0.8;
		[buttonColour release];
		buttonColour = [[UIColor alloc] initWithRed:r green:g blue:b alpha:1.0];
	}
	
	// Now make the highlight and shadow

	CGFloat rh = r + 0.2; if(rh > 1.0) rh = 1.0;
	CGFloat gh = g + 0.2; if(gh > 1.0) gh = 1.0;
	CGFloat bh = b + 0.2; if(bh > 1.0) bh = 1.0;
	highlight = [[UIColor alloc] initWithRed:rh green:gh blue:bh alpha:1.0];
	
	CGFloat rs = r * 0.7;
	CGFloat gs = g * 0.7;
	CGFloat bs = b * 0.7;
	shadow = [[UIColor alloc] initWithRed:rs green:gs blue:bs alpha:1.0];
	
	UIColor * white = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];

	// Create rounded path filling the bounds
	CGRect bounds = [self bounds];
	
	float x0 = bounds.origin.x + 1;
	float y0 = bounds.origin.y + 1;
	float x1 = x0 + bounds.size.width - 2;
	float y1 = y0 + bounds.size.height - 2;
	
	float rad = 10.0;
	
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
	CGColorRef colors[] = {[shadow CGColor], [highlight CGColor], [white CGColor], [highlight CGColor], [shadow CGColor]};
	CFArrayRef colorsArray = CFArrayCreate(NULL, (void *)colors, 5, &kCFTypeArrayCallBacks);
	
	CGFloat locations[] = {0.0, 0.1, 0.4, 0.6, 1.0};
	
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
	
	//CGContextBeginPath (context);
	//CGContextAddPath(context, path);
	//[outlineColour set];
	//CGContextStrokePath (context);
	
	CGPathRelease(path);
}

@end
