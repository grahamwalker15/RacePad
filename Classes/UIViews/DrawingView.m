//
//  DrawingView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingView.h"
#import "DrawingViewController.h"


@implementation DrawingView

@synthesize fg_;
@synthesize bg_;

// Static members
static UIFont * title_font_ = nil;
static UIFont * big_font_ = nil;
static UIFont * control_font_ = nil;
static UIFont * bold_font_ = nil;
static UIFont * medium_bold_font_ = nil;
static UIFont * regular_font_ = nil;

static bool fonts_initialised_ = false;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self setContentMode:UIViewContentModeRedraw];
		[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[self InitialiseDrawingViewMembers];
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self setContentMode:UIViewContentModeRedraw];
		[self InitialiseDrawingViewMembers];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	current_context_ = UIGraphicsGetCurrentContext();
	current_bounds_ = [self bounds];
	
	current_size_ = current_bounds_.size;
	current_origin_ = current_bounds_.origin;
	current_bottom_left_ =  CGPointMake(current_origin_.x, current_origin_.y + current_size_.height);
	current_top_right_ =  CGPointMake(current_origin_.x + current_size_.width, current_origin_.y);
	
	current_scroll_offset_ = [self contentOffset];
	
	[self Draw: rect];
}

- (void)layoutSubviews
{
}

// Responding to Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = (UITouch *)[touches anyObject]; // We assume only one touch since multi-touch is not switched on?
	DrawingViewController * delegate = (DrawingViewController * )[self delegate];
	
	if(touch && delegate)
	{
		CGPoint point = [touch locationInView:self];
		float x = point.x;
		float y = point.y;
		
		[delegate OnTouchDownX:x Y:y];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = (UITouch *)[touches anyObject]; // We assume only one touch since multi-touch is not switched on?
	DrawingViewController * delegate = (DrawingViewController * )[self delegate];
	
	if(touch && delegate)
	{
		CGPoint point = [touch locationInView:self];
		float x = point.x;
		float y = point.y;
		
		[delegate OnTouchMoveX:x Y:y];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = (UITouch *)[touches anyObject]; // We assume only one touch since multi-touch is not switched on?
	DrawingViewController * delegate = (DrawingViewController * )[self delegate];
	
	if(touch && delegate)
	{
		CGPoint point = [touch locationInView:self];
		float x = point.x;
		float y = point.y;
		
		[delegate OnTouchUpX:x Y:y];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch * touch = (UITouch *)[touches anyObject]; // We assume only one touch since multi-touch is not switched on?
	DrawingViewController * delegate = (DrawingViewController * )[self delegate];
	
	if(touch && delegate)
	{
		CGPoint point = [touch locationInView:self];
		float x = point.x;
		float y = point.y;
		
		[delegate OnTouchCancelledX:x Y:y];
	}
}

// Destruction
- (void)dealloc
{
    [fg_ release];
    [bg_ release];
	
	[self setDelegate:nil];
	
    [super dealloc];
}

 
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 
	 
- (void)InitialiseDrawingViewMembers
{
	[self InitialiseFonts];
	
	fg_ = [self CreateColourRed:255 Green:255 Blue:255]; // White
	bg_ = [self CreateColourRed:0 Green:0 Blue:0]; // Black
	
	current_font_ = regular_font_;
	current_context_ = nil;
	
	entered_ = false;
	
	last_x_ = 0;
	last_y_ = 0;
		
}

- (void)InitialiseImageDrawing
{
}

- (void)InitialiseFonts
{
	if(!fonts_initialised_)
	{
		fonts_initialised_ = true;

		title_font_ = [UIFont boldSystemFontOfSize:36.0];
		big_font_ = [UIFont boldSystemFontOfSize:32.0];
		control_font_ = [UIFont boldSystemFontOfSize:12.0];
		bold_font_ = [UIFont boldSystemFontOfSize:20.0];
		medium_bold_font_ = [UIFont boldSystemFontOfSize:28.0];
		regular_font_ = [UIFont boldSystemFontOfSize:20.0];
	}
}

- (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b
{
	return [[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0];
}

- (UIColor *)CreateColourRed:(int)r Green:(int)g Blue:(int)b Alpha:(int)a
{
	return [[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:(CGFloat)a];
}

// Basic utilities

- (CGSize)InqSize
{
	return current_size_;
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

- (void)SetDropShadowXOffset:(float)xoffset YOffset:(float)yoffset Blur:(float)blur  // N.B. Need a save/restore around it to switch off
{
	if(current_context_)
		CGContextSetShadow (current_context_, CGSizeMake((CGFloat)xoffset, (CGFloat)yoffset), (CGFloat)blur);
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

- (void)LineRectangleX0:(float)x0 Y0:(float)y0 X1:(float)x1 Y1:(float)y1
{
	[self LineRectangle:CGRectMake((CGFloat)x0, (CGFloat)y0, (CGFloat)(x1-x0), (CGFloat)(y1-y0))];
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

- (void)GetStringBox:(NSString *)string WidthReturn:(float *)width HeightReturn:(float *)height
{
	CGSize size = [string sizeWithFont:current_font_];
	*width = size.width;
	*height = size.height;
}

- (void)UseTitleFont
{
	current_font_ = title_font_;
}

- (void)UseBigFont
{
	current_font_ = big_font_;
}

- (void)UseControlFont
{
	current_font_ = control_font_;
}

- (void)UseBoldFont
{
	current_font_ = bold_font_;
}

- (void)UseMediumBoldFont
{
	current_font_ = medium_bold_font_;
}

- (void)UseRegularFont
{
	current_font_ = regular_font_;
}
 
- (void)SelectUIFont
{
}

// Matrix manipulation

- (void)SetScale:(float)scale
{
	if(current_context_)
		CGContextScaleCTM(current_context_, scale, scale);
}

- (void)SetTranslateX:(float)x Y:(float)y
{
	if(current_context_)
		CGContextTranslateCTM(current_context_, x, y);
}
 
// Scrolling support

- (void)SetContentWidth:(float)width AndHeight:(float)height
{
	[self setContentSize:CGSizeMake(width, height)];
}

@end
