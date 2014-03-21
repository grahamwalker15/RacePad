//
//  DrawingView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingView.h"

#import <math.h>

@implementation DrawingView

@synthesize fg_;
@synthesize bg_;

@synthesize double_tap_enabled_;

@synthesize black_;
@synthesize white_;
@synthesize blue_;
@synthesize orange_;
@synthesize yellow_;
@synthesize red_;
@synthesize green_;
@synthesize cyan_;
@synthesize dark_blue_;
@synthesize dark_red_;
@synthesize light_blue_;
@synthesize dark_grey_;
@synthesize very_dark_grey_;
@synthesize light_grey_;
@synthesize very_light_blue_;
@synthesize very_light_grey_;
@synthesize light_orange_;
@synthesize magenta_;
@synthesize dark_magenta_;

// Static members

static UIColor * shadow_colour_;

static bool statics_initialised_ = false;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self setDelaysContentTouches:false];
		[self setContentMode:UIViewContentModeRedraw];
		[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[self InitialiseDrawingViewMembers];
        
        font_stack_id_ = [[NSMutableArray alloc] init];
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self setDelaysContentTouches:false];
		[self setContentMode:UIViewContentModeRedraw];
		[self InitialiseDrawingViewMembers];

        font_stack_id_ = [[NSMutableArray alloc] init];
  }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	[self getCurrentBoundsInfo];
	
	[self Draw: rect];
}

- (void)getCurrentBoundsInfo
{
	current_context_ = UIGraphicsGetCurrentContext();
	
	current_bounds_ = [self bounds];
	
	current_size_ = current_bounds_.size;
	current_origin_ = current_bounds_.origin;
	current_bottom_left_ =  CGPointMake(current_origin_.x, current_origin_.y + current_size_.height);
	current_top_right_ =  CGPointMake(current_origin_.x + current_size_.width, current_origin_.y);
	
	current_scroll_offset_ = [self contentOffset];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

// Destruction
- (void)dealloc
{
    [fg_ release];
    [bg_ release];
	
	[black_ release];
	[white_ release];
	[blue_ release];
	[orange_ release];
	[yellow_ release];
	[red_ release];
	[green_ release];
	[cyan_ release];
	[dark_blue_ release];
	[dark_red_ release];
	[light_blue_ release];
	[dark_grey_ release];
	[very_dark_grey_ release];
	[light_grey_ release];
	[very_light_blue_ release];
	[very_light_grey_ release];
	[light_orange_ release];
	[magenta_ release];
	[dark_magenta_ release];
	
	[self setDelegate:nil];
	
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseDrawingViewMembers
{
	[self InitialiseStatics];
	
	fg_ = [DrawingView CreateColourRed:255 Green:255 Blue:255]; // White
	bg_ = [DrawingView CreateColourRed:0 Green:0 Blue:0]; // Black
	
    [self UseFont:DW_BOLD_FONT_];
    
	current_context_ = nil;
	bitmap_context_ = nil;
	bitmap_context_data_ = nil;
	
	black_ = [DrawingView CreateColourRed:0 Green:0 Blue:0];
	white_ = [DrawingView CreateColourRed:255 Green:255 Blue:255];
	blue_ = [DrawingView CreateColourRed:0 Green:0 Blue:255];
	orange_ = [DrawingView CreateColourRed:200 Green:140 Blue:0];
	light_orange_ = [DrawingView CreateColourRed:250 Green:180 Blue:0];
	yellow_ = [DrawingView CreateColourRed:255 Green:255 Blue:0];
	red_ = [DrawingView CreateColourRed:255 Green:0 Blue:0];
	green_ = [DrawingView CreateColourRed:0 Green:255 Blue:0];
	cyan_ = [DrawingView CreateColourRed:0 Green:255 Blue:255];
	dark_red_ = [DrawingView CreateColourRed:150 Green:0 Blue:0];
	dark_blue_ = [DrawingView CreateColourRed:0 Green:0 Blue:150];
	light_blue_ = [DrawingView CreateColourRed:120 Green:150 Blue:220];
	dark_grey_ = [DrawingView CreateColourRed:130 Green:130 Blue:130];
	very_dark_grey_ = [DrawingView CreateColourRed:60 Green:60 Blue:60];
	light_grey_ = [DrawingView CreateColourRed:200 Green:200 Blue:200];
	very_light_blue_ = [DrawingView CreateColourRed:220 Green:240 Blue:255];
	very_light_grey_ = [DrawingView CreateColourRed:220 Green:220 Blue:220];
	magenta_ = [DrawingView CreateColourRed:255 Green:0 Blue:255];
	dark_magenta_ = [DrawingView CreateColourRed:150 Green:20 Blue:100];
	
	current_matrix_ = CGAffineTransformIdentity;
	
	entered_ = false;
	double_tap_enabled_= false;
	
	last_x_ = 0;
	last_y_ = 0;
	
}

- (void)InitialiseImageDrawing
{
}

- (void)InitialiseStatics
{
	if(!statics_initialised_)
	{
		statics_initialised_ = true;
 		
		shadow_colour_ = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
	}
}

+ (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b
{
	return [[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0];
}

+ (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b Alpha:(float)a
{
	return [[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:(CGFloat)a];
}

- (UIColor *)CreateHighlightColourFromColour:(UIColor *)source
{
	int component_count = CGColorGetNumberOfComponents ([source CGColor]);
	
	if(component_count < 3)
	{
		[source retain];
		return source;
	}
	
	const CGFloat *components = CGColorGetComponents([source CGColor]);
	
	float rh = components[0] + 0.4; if(rh > 1.0) rh = 1.0;
	float gh = components[1] + 0.4; if(gh > 1.0) gh = 1.0;
	float bh = components[2] + 0.4; if(bh > 1.0) bh = 1.0;
	float a = component_count >= 4 ? components[3] : 1.0;
	return [[UIColor alloc] initWithRed:(CGFloat)rh green:(CGFloat)gh blue:(CGFloat)bh alpha:(CGFloat)a];
}

- (UIColor *)CreateShadowColourFromColour:(UIColor *)source
{
	int component_count = CGColorGetNumberOfComponents ([source CGColor]);
	
	if(component_count < 3)
	{
		[source retain];
		return source;
	}
	
	const CGFloat *components = CGColorGetComponents([source CGColor]);
	
	float rs = components[0] * 0.7;
	float gs = components[1] * 0.7;
	float bs = components[2] * 0.7;
	float a = component_count >= 4 ? components[3] : 1.0;
	return [[UIColor alloc] initWithRed:(CGFloat)rs green:(CGFloat)gs blue:(CGFloat)bs alpha:(CGFloat)a];
}

// Basic utilities

- (CGSize)InqSize
{
	return current_size_;
}

- (bool)CreateBitmapContext
{
	if(bitmap_context_)
		[self DestroyBitmapContext];
	
	int current_width = current_size_.width;
	int current_height = current_size_.height;
	
	// Make a new image context
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	bitmap_context_data_ = malloc(current_width * current_height * 4);
	memset(bitmap_context_data_, 0, current_width * current_height * 4);
	bitmap_context_ = CGBitmapContextCreate ( bitmap_context_data_, current_width, current_height, 8, current_width * 4, colorspace, kCGImageAlphaPremultipliedLast );
	CGColorSpaceRelease(colorspace);
	
	if(bitmap_context_)
	{
		// Set this to be the current context
		UIGraphicsPushContext (bitmap_context_);
		current_context_ = UIGraphicsGetCurrentContext();
		
		return true;		
	}
	else
	{
		free(bitmap_context_data_);
		bitmap_context_data_ = nil;
		return false;
	}
	
	
}

- (CGImageRef)GetImageFromBitmapContext
{
	if(bitmap_context_)
		return CGBitmapContextCreateImage (bitmap_context_);
	else
		return nil;
	
}

- (void)DestroyBitmapContext
{
	if(bitmap_context_)
	{
		// Restore the old context
		UIGraphicsPopContext ();
		current_context_ = UIGraphicsGetCurrentContext();
		
		CGContextRelease (bitmap_context_);
		bitmap_context_ = nil;
		
		free(bitmap_context_data_);
		bitmap_context_data_ = nil;		
	}
	
}

- (void)SetBGToShadowColour
{
	[self SetBGColour:shadow_colour_];
}

- (void)SetAlpha:(float)alpha
{
	if(current_context_)
		CGContextSetAlpha(current_context_, alpha);
}

// View drawing

- (void)RequestRedraw
{
	[self setNeedsDisplay];
}

- (void)RequestRedrawInRect:(CGRect)rect
{
	[self setNeedsDisplayInRect:rect];
}

- (void) RequestRedrawForUpdate
{
	[self RequestRedraw];
}

- (void)Draw
{
	[self Draw:[self bounds]];
}

- (void)Draw:(CGRect) rect
{
	[self UseBoldFont];
	[self DrawString:@"Default Drawing Window" AtX:20 Y:20];
}

// 
// Drawing primitives
// Lines & text drawn in foreground colour
// Fills and text bg drawn in background colour
//

- (void)ClearScreen
{
	if(current_context_)
		CGContextClearRect(current_context_, current_bounds_);
}
- (void)SaveGraphicsState
{
	if(current_context_)
		CGContextSaveGState (current_context_);
}

- (void)RestoreGraphicsState
{
	if(current_context_)
		CGContextRestoreGState (current_context_);
}

- (void)BeginDrawing
{
}

- (void)EndDrawing
{
}

- (void)SetClippingArea:(CGRect)rect // N.B. Sets it to an intersection with current clip area. Need a save/restore around it
{
	if(current_context_)
		CGContextClipToRect (current_context_, rect);
}

- (void)SetClippingAreaToPath:(CGMutablePathRef)path // N.B. Sets it to an intersection with current clip area. Need a save/restore around it
{
	if(current_context_)
	{
		CGContextBeginPath (current_context_);
		CGContextAddPath(current_context_, path);
		CGContextClip (current_context_);
	}
}

- (void)SetLineWidth:(float)width
{
	if(current_context_)
		CGContextSetLineWidth (current_context_, (CGFloat)width);
}

- (void)SetSolidLine
{
	if(current_context_)
		CGContextSetLineDash (current_context_, 0.0, NULL, 0);
}

- (void)SetDashedLine
{
	if(current_context_)
	{
		CGFloat lengths[2];
		lengths[0] = lengths[1] = 5.0;
		CGContextSetLineDash (current_context_, 0.0, lengths, 2);
	}
}

- (void)SetDashedLine:(float) length
{
	if(current_context_)
	{
		CGFloat lengths[2];
		lengths[0] = lengths[1] = length;
		CGContextSetLineDash (current_context_, 0.0, lengths, 2);
	}
}

- (void)SetDropShadowXOffset:(float)xoffset YOffset:(float)yoffset Blur:(float)blur  // N.B. Need a save/restore around it to switch off
{
	if(current_context_)
		CGContextSetShadow (current_context_, CGSizeMake((CGFloat)xoffset, (CGFloat)yoffset), (CGFloat)blur);
}

- (void)ResetDropShadow
{
	if(current_context_)
		CGContextSetShadowWithColor(current_context_, CGSizeMake(0, 0), 0, NULL);
}

- (void)LineX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	if(current_context_)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextMoveToPoint (current_context_, (CGFloat)x0, (CGFloat)y0);
		CGContextAddLineToPoint (current_context_, (CGFloat)x1, (CGFloat)y1);
		CGContextStrokePath (current_context_);
	}
}

- (void)LinePoint0:(CGPoint)p0 Point1:(CGPoint)p1
{
	if(current_context_)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextMoveToPoint (current_context_, p0.x, p0.y);
		CGContextAddLineToPoint (current_context_, p1.x, p1.y);
		CGContextStrokePath (current_context_);
	}
}

- (void)FillRectangle:(CGRect)rect
{
	if(current_context_)
	{
		[bg_ set];
		CGContextFillRect(current_context_, rect);
	}
}

- (void)FillShadedRectangle:(CGRect)rect WithHighlight:(bool)ifHighlight
{
	if(current_context_)
	{
		// Vertical gradient based on current background colour
		UIColor * highlight = [self CreateHighlightColourFromColour:bg_];
		UIColor * shadow = [self CreateShadowColourFromColour:bg_];
		
		CGContextSaveGState(current_context_);
		CGContextClipToRect(current_context_, rect);
		
		CGGradientRef gradient;
		
		if(ifHighlight)
		{
			CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			CGColorRef colors[] = {[highlight CGColor], [white_ CGColor], [highlight CGColor], [shadow CGColor]};
			CFArrayRef colorsArray = CFArrayCreate(NULL, (void *)colors, 4, &kCFTypeArrayCallBacks);
			
			CGFloat locations[] = {0.0, 0.4, 0.6, 1.0};
			
			gradient = CGGradientCreateWithColors(colorspace, colorsArray, locations);
			
			CFRelease(colorsArray);
			CGColorSpaceRelease(colorspace);
		}
		else
		{
			CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
			CGColorRef colors[] = {[highlight CGColor], [bg_ CGColor], [shadow CGColor]};
			CFArrayRef colorsArray = CFArrayCreate(NULL, (void *)colors, 3, &kCFTypeArrayCallBacks);
			
			gradient = CGGradientCreateWithColors(colorspace, colorsArray, NULL);
			
			CFRelease(colorsArray);
			CGColorSpaceRelease(colorspace);
		}
		
		CGPoint start_point = rect.origin;
		CGPoint end_point = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
		CGContextDrawLinearGradient(current_context_, gradient, start_point, end_point, 0);
		
		CGGradientRelease(gradient);
		
		[highlight release];
		[shadow release];
		
		CGContextRestoreGState(current_context_);
		
	}
}

- (void)FillGlassRectangle:(CGRect)rect
{
	if(current_context_)
	{
		// Vertical gradient with varying degrees of transparency
		
		CGContextSaveGState(current_context_);
		CGContextClipToRect(current_context_, rect);
		
		UIColor * c1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
		UIColor * c2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
		UIColor * c3 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
		UIColor * c4 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0];
		UIColor * c5 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4];
		
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGColorRef colors[] = {[c1 CGColor], [c2 CGColor], [c3 CGColor], [c4 CGColor], [c5 CGColor]};
		CFArrayRef colorsArray = CFArrayCreate(NULL, (void *)colors, 5, &kCFTypeArrayCallBacks);
		
		CGFloat locations[] = {0.0, 0.2, 0.4, 0.5, 1.0};
		
		CGGradientRef gradient = CGGradientCreateWithColors(colorspace, colorsArray, locations);
		
		CFRelease(colorsArray);
		CGColorSpaceRelease(colorspace);
		
		CGPoint start_point = rect.origin;
		CGPoint end_point = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
		CGContextDrawLinearGradient(current_context_, gradient, start_point, end_point, 0);
		
		CGGradientRelease(gradient);
		
		CGContextRestoreGState(current_context_);
		
	}
}

- (void)LineRectangle:(CGRect)rect
{
	if(current_context_)
	{
		[fg_ set];
		CGContextStrokeRect(current_context_, rect);
	}
}

- (void)FillRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	[self FillRectangle:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0))];
}

- (void)FillShadedRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 WithHighlight:(bool)ifHighlight
{
	[self FillShadedRectangle:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0)) WithHighlight:ifHighlight];
}

- (void)FillGlassRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	[self FillGlassRectangle:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0))];
}

- (void) FillPatternRectangle:(UIImage *)image X0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	[image drawAsPatternInRect:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0))];
}

- (void)LineRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	[self LineRectangle:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0))];
}

- (void)LineCircle:(float)x0 Y0:(float)y0 Radius:(float)r;
{
	if(current_context_)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextAddArc(current_context_, x0, y0, r, 0, M_PI * 2, true);
		CGContextStrokePath (current_context_);
	}
}

- (void)LineArc:(float)x0 Y0:(float)y0 StartAngle:(float)startAngle EndAngle:(float)endAngle Clockwise:(bool) clockwise Radius:(float)r;
{
	if(current_context_)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextAddArc(current_context_, x0, y0, r, startAngle, endAngle, clockwise);
		CGContextStrokePath (current_context_);
	}
}

- (void)FillArc:(float)x0 Y0:(float)y0 StartAngle:(float)startAngle EndAngle:(float)endAngle Clockwise:(bool) clockwise Radius:(float)r;
{
	if(current_context_)
	{
		[bg_ set];
		CGContextBeginPath (current_context_);
		CGContextMoveToPoint (current_context_, x0, y0);
		CGContextAddArc(current_context_, x0, y0, r, startAngle, endAngle, clockwise);
		CGContextClosePath (current_context_);
		CGContextFillPath (current_context_);
	}
}

- (void)EtchRectangle:(CGRect)rect EtchIn:(bool)etch_in
{
}

- (void)FillPolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;
{
	if(current_context_ && point_count > 2)
	{
		[bg_ set];
		CGContextBeginPath (current_context_);
		CGContextMoveToPoint (current_context_, (CGFloat)x[0], (CGFloat)y[0]);
		
		for ( int i = 1 ; i < point_count ; i++)
		{
			CGContextAddLineToPoint (current_context_, (CGFloat)x[i], (CGFloat)y[i]);
		}
		
		CGContextClosePath (current_context_);
		
		CGContextFillPath (current_context_);
	}
}

- (void)LinePolygonPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y;
{
	if(current_context_ && point_count > 1)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextMoveToPoint (current_context_, (CGFloat)x[0], (CGFloat)y[0]);
		
		for ( int i = 1 ; i < point_count ; i++)
		{
			CGContextAddLineToPoint (current_context_, (CGFloat)x[i], (CGFloat)y[i]);
		}
		
		CGContextClosePath (current_context_);
		
		CGContextStrokePath (current_context_);
	}
}

+ (CGMutablePathRef)CreatePathPoints:(int)point_count XCoords:(float *)x YCoords:(float *)y
{
	if(point_count < 2)
		return nil;
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x[0], (CGFloat)y[0]);
	
	for ( int i = 1 ; i < point_count ; i++)
	{
		CGPathAddLineToPoint (path, nil, (CGFloat)x[i], (CGFloat)y[i]);
	}
	
	return path;
}

+ (CGMutablePathRef)CreatePathPoints:(int)p0 P1:(int)p1 XCoords:(float *)x YCoords:(float *)y Count:(int) count
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x[p0], (CGFloat)y[p0]);
	
	int p = p0;
	while (true )
	{
		p++;
		if ( p >= count )
			p = 0;
		CGPathAddLineToPoint (path, nil, (CGFloat)x[p], (CGFloat)y[p]);
		if ( p == p1 )
			break;
	}
	
	return path;
}


+ (CGMutablePathRef)CreateTrianglePathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 X2:(float)x2 Y2:(float)y2
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x0, (CGFloat)y0);
	CGPathAddLineToPoint (path, nil, (CGFloat)x1, (CGFloat)y1);
	CGPathAddLineToPoint (path, nil, (CGFloat)x2, (CGFloat)y2);
	CGPathAddLineToPoint (path, nil, (CGFloat)x0, (CGFloat)y0);
	
	return path;
}

+ (CGMutablePathRef)CreateRectPathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1;
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x0, (CGFloat)y0);
	CGPathAddLineToPoint (path, nil, (CGFloat)x0, (CGFloat)y1);
	CGPathAddLineToPoint (path, nil, (CGFloat)x1, (CGFloat)y1);
	CGPathAddLineToPoint (path, nil, (CGFloat)x1, (CGFloat)y0);
	CGPathAddLineToPoint (path, nil, (CGFloat)x0, (CGFloat)y0);
	
	return path;
}

+ (CGMutablePathRef)CreateRoundedRectPathX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1 Radius:(float)r;
{
	CGMutablePathRef path = CGPathCreateMutable();
	
	// Make sure both x and y are increasing
	if(x0 > x1)
	{
		float tx = x0;
		x0 = x1;
		x1 = tx;
	}
	
	if(y0 > y1)
	{
		float ty = y0;
		y0 = y1;
		y1 = ty;
	}
	
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
	
	return path;
}

- (void)BeginPath
{
	if(current_context_)
		CGContextBeginPath (current_context_);
}

- (void)LoadPath:(CGMutablePathRef)path
{
	if(current_context_)
	{
		CGContextAddPath(current_context_, path);
		// CGContextClosePath(current_context_);
	}
}

- (void)FillCurrentPath
{
	if(current_context_)
	{
		[bg_ set];
		CGContextEOFillPath (current_context_);
	}
}

- (void)LineCurrentPath
{
	if(current_context_)
	{
		[fg_ set];
		CGContextStrokePath (current_context_);
	}
}

- (void)FillPath:(CGMutablePathRef)path
{
	if(current_context_)
	{
		[bg_ set];
		CGContextBeginPath (current_context_);
		CGContextAddPath(current_context_, path);
		CGContextFillPath (current_context_);
	}
}

- (void)LinePath:(CGMutablePathRef)path
{
	if(current_context_)
	{
		[fg_ set];
		CGContextBeginPath (current_context_);
		CGContextAddPath(current_context_, path);
		CGContextStrokePath (current_context_);
	}
}

- (void)SetXorLines:(bool)set
{
}

//
// Image Drawing
//

- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y
{
	[image drawAtPoint:CGPointMake(x, y)];
}

- (void) DrawImage:(UIImage *)image AtX:(float)x Y:(float)y WithAlpha:(float)alpha
{
	[image drawAtPoint:CGPointMake(x, y) blendMode:kCGBlendModeNormal alpha:alpha];
}

- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect
{
	[image drawInRect:rect];
}

- (void) DrawImage:(UIImage *)image InRect:(CGRect)rect WithAlpha:(float)alpha
{
	[image drawInRect:rect blendMode:kCGBlendModeNormal alpha:alpha];
}

- (void) DrawPattern:(UIImage *)image InRect:(CGRect)rect
{
	[image drawAsPatternInRect:rect];
}

//
// Text Drawing
//

- (void)DrawString:(NSString *)string AtX:(float)x Y:(float)y
{
	[fg_ set];
	[string drawAtPoint:CGPointMake(x,y) withFont:current_font_];
}

- (void)DrawClippedString:(NSString *)string AtX:(float)x Y:(float)y MaxWidth: (float)max_width
{
	[fg_ set];
	[string drawAtPoint:CGPointMake(x,y) withFont:current_font_];
}

- (void)DrawMultiLineString:(NSString *)string AtX:(float)x Y:(float)y MaxWidth:(float)max_width Height:(float)max_height
{
	[fg_ set];
	[string drawInRect:CGRectMake(x,y,max_width,max_height) withFont:current_font_];
}

- (void)GetStringBox:(NSString *)string WidthReturn:(float *)width HeightReturn:(float *)height
{
	CGSize size = [string sizeWithFont:current_font_];
	*width = size.width;
	*height = size.height;
}

- (void)UseFont:(int)font
{
    current_font_id_ = font;
	switch(current_font_id_)
	{			
		case DW_LIGHT_CONTROL_FONT_:
			current_font_ = [UIFont systemFontOfSize:12.0];
			break;
			
		case DW_LIGHT_LARGER_CONTROL_FONT_:
			current_font_ = [UIFont systemFontOfSize:13.0];
			break;
			
		case DW_LIGHT_BIG_FONT_:
			current_font_ = [UIFont systemFontOfSize:32.0];
			break;
			
		case DW_LIGHT_REGULAR_FONT_:
			current_font_ = [UIFont systemFontOfSize:20.0];
			break;
			
		case DW_TITLE_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:36.0];
			break;
			
		case DW_CONTROL_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:12.0];
			break;
			
		case DW_LARGER_CONTROL_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:13.0];
			break;
			
		case DW_BOLD_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:20.0];
 			break;
			
		case DW_MEDIUM_BOLD_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:16.0];
 			break;
			
		case DW_BIG_FONT_:
			current_font_ = [UIFont boldSystemFontOfSize:32.0];
			break;
			
		case DW_ITALIC_LARGER_CONTROL_FONT_:
			current_font_ = [UIFont italicSystemFontOfSize:13.0];
			break;
			
		case DW_ITALIC_REGULAR_FONT_:
			current_font_ = [UIFont italicSystemFontOfSize:20.0];
			break;
			
		case DW_ITALIC_BIG_FONT_:
			current_font_ = [UIFont italicSystemFontOfSize:32.0];
			break;
			
		case DW_REGULAR_FONT_:
		default:
			[self UseFont:DW_BOLD_FONT_];
			break;
	}
}

- (void)UseTitleFont
{
    [self UseFont:DW_TITLE_FONT_];
}

- (void)UseBigFont
{
    [self UseFont:DW_BIG_FONT_];
}

- (void)UseControlFont
{
    [self UseFont:DW_CONTROL_FONT_];
}

- (void)UseLargerControlFont
{
    [self UseFont:DW_LARGER_CONTROL_FONT_];
}

- (void)UseBoldFont
{
    [self UseFont:DW_BOLD_FONT_];
}

- (void)UseMediumBoldFont
{
    [self UseFont:DW_MEDIUM_BOLD_FONT_];
}

- (void)UseRegularFont
{
    [self UseFont:DW_BOLD_FONT_];
}

- (void)SelectUIFont
{
}

- (void)SaveFont
{
    [font_stack_id_ addObject:[NSNumber numberWithInteger:current_font_id_]];
}

- (void)RestoreFont
{
	if([font_stack_id_ count] > 0)
	{
        current_font_id_ = [[font_stack_id_ lastObject] integerValue];
		[self UseFont:current_font_id_];
		[font_stack_id_ removeLastObject];
	}
}

// Matrix manipulation

- (void)SetScale:(float)scale
{
	if(current_context_)
		CGContextScaleCTM(current_context_, scale, scale);
}

- (void)SetScaleX:(float)scale_x Y:(float)scale_y
{
	if(current_context_)
		CGContextScaleCTM(current_context_, scale_x, scale_y);
}

- (void)SetTranslateX:(float)x Y:(float)y
{
	if(current_context_)
		CGContextTranslateCTM(current_context_, x, y);
}

- (void)SetRotation:(float)angle
{
	if(current_context_)
		CGContextRotateCTM(current_context_, angle);
}

- (void)SetRotationInDegrees:(float)angle
{
	if(current_context_)
		CGContextRotateCTM(current_context_, angle * M_PI / 180.0);
}

- (void)StoreTransformMatrix
{
	if(current_context_)
		current_matrix_ = CGContextGetCTM(current_context_);
}

- (void)ResetTransformMatrix
{
	current_matrix_ = CGAffineTransformIdentity;
}

- (CGPoint)TransformPoint:(CGPoint)point
{
	float screenScale = [self contentScaleFactor];
	CGPoint transformedPoint = CGPointApplyAffineTransform (point, current_matrix_);
	if(screenScale > 1.0)
	{
		transformedPoint.x = transformedPoint.x / screenScale;
		transformedPoint.y = transformedPoint.y / screenScale;
	}
	
	return transformedPoint;
}

// Scrolling support

- (void)SetContentWidth:(float)width AndHeight:(float)height
{
	[self setContentSize:CGSizeMake(width, height)];
}


//////////////////////////////////////////////////////////////////////////
//  User Interaction
//////////////////////////////////////////////////////////////////////////

/*
 -(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 {
 if([touches count] > 0)
 {
 // Get the first touch object
 NSEnumerator *enumerator = [mySet objectEnumerator];
 UITouch * touch;
 
 if(touch = [enumerator nextObject])
 {
 
 }
 }
 }
 
 – touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
 {
 }
 
 – touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
 {
 }
 
 – touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
 {
 }
 */

@end
