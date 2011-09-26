//
//  Pitch.m
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Pitch.h"
#import "DataStream.h"
#import "PitchView.h"
#import "MathOdds.h"
#import "ImageListStore.h"
#import "MatchPadDatabase.h"

@implementation PitchLine

@synthesize colour;
@synthesize lineType;
@synthesize x0;
@synthesize y0;
@synthesize x1;
@synthesize y1;

- (id) init
{
	if(self = [super init])
	{
		colour = nil;
		x0 = 0;
		y0 = 0;
		x1 = 0;
		y1 = 0;
	}
	
	return self;
}

- (void) clear
{
	[colour release];
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

- (UIColor *) loadColour: (DataStream *)stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		return [colours[index] retain];
	
	return nil;
}

-(void) loadShape:(DataStream *)stream Count:(int)count Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	int i;
	for ( i = 0; i < count; i++ )
	{
		if ( i == 0 )
		{
			x0 = [stream PopFloat];
			y0 = 1 - [stream PopFloat];
		}
		else if ( i == 1 )
		{
			x1 = [stream PopFloat];
			y1 = 1 - [stream PopFloat];
		}
		else
		{
			[stream PopFloat];
			[stream PopFloat];
		}
	}
	
	colour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	lineType = [stream PopUnsignedChar];
}

@end

@implementation Pitch

- (id) init
{
	if(self = [super init])
	{
		lines = [[NSMutableArray alloc] init];
		xCentre = 0.0;
		yCentre = 0.0;
		
		width = 0.0;
		height = 0.0;
		
		// playerBG = [DrawingView CreateColourRed:220 Green:220 Blue:220];
		pitchColour = [DrawingView CreateColourRed:118 Green:158 Blue:58];
		[self initialisePerspective];
	}
	
	return self;
}

- (void) dealloc
{
	[lines release];

	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	[player release];
	[playerColour release];
	
	[super dealloc];
}

- (void) loadPitch : (DataStream *) stream
{
	[lines removeAllObjects];

	width = 0.0;
	height = 0.0;
	
	xCentre = 0.0;
	yCentre = 0.0;
	
	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	coloursCount = [stream PopInt];
	colours = malloc ( sizeof (UIColor *) * coloursCount );
	
	for ( c = 0; c < coloursCount; c++ )
		colours[c] = NULL;
	
	for ( c = 0; c < coloursCount; c++ )
	{
		unsigned char index = [stream PopUnsignedChar];
		UIColor *colour = [[stream PopRGBA] retain];
		if ( index < coloursCount )
			colours[index] = colour;
		else
			[colour release];
	}
	
	while ( true )
	{
		int count = [stream PopInt];
		if ( count < 0 )
			break;
		PitchLine *line = [[PitchLine alloc] init];
		[line loadShape:stream Count:count Colours:colours ColoursCount:coloursCount];
		[lines addObject:line];
		[line release];
	}
	
	playerX = [stream PopFloat];
	playerY = 1 - [stream PopFloat];
	[player release];
	player = [[stream PopString] retain];
	[playerColour release];
	playerColour = NULL;
	[playerBG release];
	playerBG = NULL;
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		playerColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		playerBG = [colours[index] retain];
	
	nextPlayerX = [stream PopFloat];
	nextPlayerY = 1 - [stream PopFloat];
	[nextPlayer release];
	nextPlayer = [[stream PopString] retain];
	[nextPlayerColour release];
	nextPlayerColour = NULL;
	[nextPlayerBG release];
	nextPlayerBG = NULL;
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		nextPlayerColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		nextPlayerBG = [colours[index] retain];
	
	thirdX = [stream PopFloat];
	thirdY = 1 - [stream PopFloat];
	[third release];
	third = [[stream PopString] retain];
	[thirdColour release];
	thirdColour = NULL;
	[thirdBG release];
	thirdBG = NULL;
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		thirdColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		thirdBG = [colours[index] retain];
}

-(void) initialisePerspective
{
	float x3 = 0;
	float y3 = 1;
	float x2 = 1;
	float y2 = 1;
	float x1 = 0.8;
	float y1 = 0;
	float x0 = 0.2;
	float y0 = 0;
	
	float dx1 = x1-x2;
	float dy1 = y1-y2;
	float dx2 = x3-x2;
	float dy2 = y3-y2;
	float dx3 = x0-x1+x2-x3;
	float dy3 = y0-y1+y2-y3;
	
	if (dx3 == 0 && dy3 == 0) {
		a11 = x1-x0;
		a21 = x2-x1;
		a31 = x0;
		a12 = y1-y0;
		a22 = y2-y1;
		a32 = y0;
		a13 = a23 = 0;
	} else {
		a13 = (dx3*dy2-dx2*dy3)/(dx1*dy2-dy1*dx2);
		a23 = (dx1*dy3-dy1*dx3)/(dx1*dy2-dy1*dx2);
		a11 = x1-x0+a13*x1;
		a21 = x3-x0+a23*x3;
		a31 = x0;
		a12 = y1-y0+a13*y1;
		a22 = y3-y0+a23*y3;
		a32 = y0;
	}
}

- (void) transformPoint:(float *)x Y:(float *)y
{
	float f = 1.0f / (a13 * *x+ a23 * *y + 1);
	*x = (a11 * *x + a21 * *y + a31) * f;
	*y = (a12 * *x + a22 * *y + a32) * f;
}

- (void) viewLine: (PitchView *) view X0:(float)x0 Y0:(float) y0 X1:(float)x1 Y1:(float) y1
{
	[self transformPoint:&x0 Y:&y0];
	[self transformPoint:&x1 Y:&y1];
	[view LineX0:x0 Y0:y0 X1:x1 Y1:y1];
}

- (void) viewSpot: (PitchView *) view X0:(float)x0 Y0:(float) y0 LineScale:(float) lineScale
{
	[self transformPoint:&x0 Y:&y0];
	[view LineCircle:x0 Y0:y0 Radius:5/lineScale];
}

- (void) drawPitch: (PitchView *) view XScale: (float) xScale YScale: (float) yScale XOffset:(float) xOffset YOffset:(float) yOffset LineScale:(float)lineScale
{
	[view SaveGraphicsState];
	
	[view SetLineWidth:1.5/lineScale];
	[view SetFGColour:[view white_]];
	// Edges
	[self viewLine:view X0:0 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:1 * yScale + yOffset];
	[self viewLine:view X0:0 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:1 * yScale + yOffset];
	[self viewLine:view X0:1 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:0 * yScale + yOffset];
	[self viewLine:view X0:1 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:0 * yScale + yOffset];
	
	// Centre Line
	[self viewLine:view X0:0.5 * xScale + xOffset Y0:0 * yScale + yOffset X1:0.5 * xScale + xOffset Y1:1 * yScale + yOffset];
	// Centre Circle
	// [view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.085 * xScale];
	// [view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.002 * xScale];
	
	// LH Penalty Area
	[self viewLine:view X0:0 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[self viewLine:view X0:0.17 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[self viewLine:view X0:0.17 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	// [view LineArc:0.115 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(45) EndAngle:DegreesToRadians(315) Clockwise:true Radius:0.077 * xScale];
	// LH Goal Area
	[self viewLine:view X0:0 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[self viewLine:view X0:0.058 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[self viewLine:view X0:0.058 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	// RH Penalty Area
	[self viewLine:view X0:1 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[self viewLine:view X0:0.83 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[self viewLine:view X0:0.83 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	// [view LineArc:0.885 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(135) EndAngle:DegreesToRadians(225) Clockwise:false Radius:0.077 * xScale];
	// RH Goal Area
	[self viewLine:view X0:1 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[self viewLine:view X0:0.942 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[self viewLine:view X0:0.942 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	[view SetLineWidth:3/lineScale];
	// LH Goal
	[self viewLine:view X0:0 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.558 * yScale + yOffset];

	// RH Goal
	[self viewLine:view X0:1 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.558 * yScale + yOffset];
	
	[view RestoreGraphicsState];
}

- (void) drawPasses: (PitchView *) view Scale: (float) scale
{
	[view SaveGraphicsState];
		
	int i;
	// Now draw the other lines
	int count = [lines count];
	for ( i = 0; i < count; i++)
	{
		PitchLine *line = [lines objectAtIndex:i];
		[view SetLineWidth:3 / scale];
		[view SetFGColour:[line colour]];
		if ( [line lineType] == 3 )
		{
			[view SetSolidLine];
			[self viewSpot:view X0:[line x0] Y0:[line y0] LineScale:scale];
		}
		else
		{
			if ( [line lineType] == 2 )
				[view SetDashedLine:8.0/scale];
			else
				[view SetSolidLine];
			[self viewLine:view X0:[line x0] Y0:[line y0] X1:[line x1] Y1:[line y1]];
		}
	}
	
	[view RestoreGraphicsState];
}

- (void) initialiseTransformMatrixForView:(PitchView *)view
{
	// Constructs the transform matrix, stores it, and leaves it current
	
	// Get dimensions of current view
	CGRect map_rect = [view bounds];
	
	CGSize viewSize = map_rect.size;
	
	// Make the map as big as possible in the rectangle
	// The pitch is inset 25 pixels all round
	float x_scale = viewSize.width - 50;
	float y_scale = viewSize.height - 50;
	
	float mapXOffset, mapYOffset;
	
	
	// If it is an overlay view, we move it to the right. Otherwise centre.
	/*
	 if([view isOverlayView])
	 {
	 x_scale = x_scale * 0.7;
	 y_scale = y_scale * 0.7;
	 mapXOffset = viewSize.width - width * 0.5 * x_scale - 55 ;
	 mapYOffset = viewSize.height * 0.5 + yCentre  ;
	 }
	 else
	 {
	 x_scale = x_scale * 0.9;
	 y_scale = y_scale * 0.9;
	 mapXOffset = viewSize.width * 0.5 - xCentre  ;
	 mapYOffset = viewSize.height * 0.5 + yCentre ;
	 }
	 */
	mapXOffset = 25;
	mapYOffset = 25;
	
	[view setHomeScaleX:x_scale];
	[view setHomeScaleY:y_scale];
	[view setHomeXOffset:mapXOffset];
	[view setHomeYOffset:mapYOffset];
}

- (void) drawInView:(PitchView *)view
{
	[view SaveGraphicsState];
	
	CGRect map_rect = [view bounds];
	
	CGSize viewSize = map_rect.size;
	
	[self initialiseTransformMatrixForView:view];
	
	float x_scale = [view homeScaleX] * [view interpolatedUserScale]; // Usually just userScale unless animating
	float y_scale = [view homeScaleY] * [view interpolatedUserScale]; // Usually just userScale unless animating
	float xOffset = [view homeXOffset] + [view userXOffset] * viewSize.width;
	float yOffset = [view homeYOffset] + [view userYOffset] * viewSize.height;
	
	float x[4], y[4];
	x[0] = -0.1;
	y[0] = -0.1;
	x[1] = -0.1;
	y[1] = 1.1;
	x[2] = 1.1;
	y[2] = 1.1;
	x[3] = 1.1;
	y[3] = -0.1;
	for ( int i = 0; i < 4; i++ )
	{
		[self transformPoint:x+i Y:y+i];
		x[i] = x[i] * x_scale + xOffset;
		y[i] = y[i] * y_scale + yOffset;
	}
	
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathMoveToPoint (path, nil, (CGFloat)x[0], (CGFloat)y[0]);
	
	for ( int i = 1 ; i < 4 ; i++)
		CGPathAddLineToPoint (path, nil, (CGFloat)x[i], (CGFloat)y[i]);

	[view SetBGColour:pitchColour];
	[view FillPath:path];

	CGPathRelease(path);

	// Draw pitch outline in un-scaled space - because of the circles!
	// [self drawLines:view XScale:x_scale YScale:y_scale XOffset:xOffset YOffset:yOffset];
	
	[self constructTransformMatrixForView:view];
	
	float scale = x_scale > y_scale ? x_scale : y_scale;
	[self drawPitch:view XScale:1 YScale:1 XOffset:0 YOffset:0 LineScale:scale];
	[self drawPasses:view Scale:scale];
	
	[view RestoreGraphicsState];
	
	float centreX = (playerX + nextPlayerX ) / 2;
	float centreY = (playerY + nextPlayerY ) / 2;
	
	if ( [third length] && ![nextPlayer length] )
	{
		centreX = (playerX + thirdX ) / 2;
		centreY = (playerY + thirdY ) / 2;
	}
		
	CGRect player_rect;
	CGRect next_rect;

	if ( [player length] )
	{
		float x = playerX;
		float y = playerY;
		[self transformPoint:&x Y:&y];
		x = x * x_scale + 25;
		y = y * y_scale + 25;
		float sWidth, sHeight;
		[view GetStringBox:player WidthReturn:&sWidth HeightReturn:&sHeight];
		if ( playerX < centreX )
			x -= sWidth;
		if ( playerY < centreY )
			y -= sHeight;
		[view SetBGColour:playerBG];
		[view SetAlpha:0.4];
		[view FillRectangleX0:x - 1 Y0:y - 1 X1:x - 1 + sWidth + 2 Y1:y - 1 + sHeight + 2];
		player_rect = CGRectMake ( x - 1, y - 1, sWidth + 2, sHeight + 2 );
		[view SetAlpha:1.0];
		[view UseRegularFont];
		[view SetFGColour:playerColour];
		[view DrawString:player AtX:x Y:y];
	}
	if ( [nextPlayer length] )
	{
		float x = nextPlayerX;
		float y = nextPlayerY;
		[self transformPoint:&x Y:&y];
		x = x * x_scale + 25;
		y = y * y_scale + 25;
		float sWidth, sHeight;
		[view GetStringBox:nextPlayer WidthReturn:&sWidth HeightReturn:&sHeight];
		if ( nextPlayerX <= centreX )
			x -= sWidth;
		if ( nextPlayerY <= centreY )
			y -= sHeight;
		[view SetBGColour:nextPlayerBG];
		[view SetAlpha:0.4];
		[view FillRectangleX0:x - 1 Y0:y - 1 X1:x - 1 + sWidth + 2 Y1:y - 1 + sHeight + 2];
		next_rect = CGRectMake ( x - 1, y - 1, sWidth + 2, sHeight + 2 );
		[view SetAlpha:1.0];
		[view UseRegularFont];
		[view SetFGColour:nextPlayerColour];
		[view DrawString:nextPlayer AtX:x Y:y];
	}
	if ( [third length] )
	{
		float x = thirdX;
		float y = thirdY;
		[self transformPoint:&x Y:&y];
		x = x * x_scale + 25;
		y = y * y_scale + 25;
		float sWidth, sHeight;
		[view GetStringBox:third WidthReturn:&sWidth HeightReturn:&sHeight];
		if ( [nextPlayer length] )
		{
			// try to find a place that doesn't overlap
			for ( int i = 0; i < 4; i++ )
			{
				x = thirdX;
				y = thirdY;
				[self transformPoint:&x Y:&y];
				x = x * x_scale + 25;
				y = y * y_scale + 25;
				if ( i == 1 || i == 3 )
					x -= sWidth;
				if ( i == 2 || i == 3 )
					y -= sHeight;
				CGRect third_rect = CGRectMake ( x - 1, y - 1, sWidth + 2, sHeight + 2 );
				if ( !CGRectIntersectsRect(player_rect, third_rect)
				  && !CGRectIntersectsRect(next_rect, third_rect) )
					break;
			}
		}
		else // put it where next would be
		{
			if ( thirdX <= centreX )
				x -= sWidth;
			if ( thirdY <= centreY )
				y -= sHeight;
		}
		[view SetBGColour:thirdBG];
		[view SetAlpha:0.4];
		[view FillRectangleX0:x - 1 Y0:y - 1 X1:x - 1 + sWidth + 2 Y1:y - 1 + sHeight + 2];
		[view SetAlpha:1.0];
		[view UseRegularFont];
		[view SetFGColour:thirdColour];
		[view DrawString:third AtX:x Y:y];
	}
	
}

- (void) constructTransformMatrixForView:(PitchView *)view
{
	[self constructTransformMatrixForView:view WithCentreX:xCentre Y:-yCentre Rotation:0];
}

- (void) constructTransformMatrixForView:(PitchView *)view WithCentreX:(float)x Y:(float)y Rotation:(float) rotation
{
	// Constructs the transform matrix, stores it, and leaves it current
	
	CGRect map_rect = [view bounds];
	
	CGSize viewSize = map_rect.size;

	float x_scale = [view homeScaleX];
	float y_scale = [view homeScaleY];
	float mapXOffset = [view homeXOffset];
	float mapYOffset = [view homeYOffset];
	
	float userScale = [view interpolatedUserScale];
	float userXOffset = [view userXOffset];
	float userYOffset = [view userYOffset];
	
	//  And build the matrix
	[view ResetTransformMatrix];
	
	[view SetTranslateX:userXOffset * viewSize.width Y:userYOffset * viewSize.height];	
	[view SetTranslateX:mapXOffset Y:mapYOffset];
	[view SetScaleX:x_scale * userScale Y:y_scale * userScale];
	[view SetRotationInDegrees:rotation];
	[view SetTranslateX:-x Y:-y];
	
	[view StoreTransformMatrix];	
}

- (void) adjustScaleInView:(PitchView *)view Scale:(float)scale X:(float)x Y:(float)y
{
	// If we're following a car, we just set the scale
	// Otherwise we zoom so that the focus point stays at the same screen location
	if([view isZoomView])
	{
		float currentUserScale = [view userScale];
		if(fabsf(currentUserScale) < 0.001 || fabsf(scale) < 0.001)
			return;
		
		[view setUserScale:currentUserScale * scale];
	}
	else
	{
		CGRect viewBounds = [view bounds];
		CGSize viewSize = viewBounds.size;

		if(viewSize.width < 1 || viewSize.height < 1)
			return;

		float currentUserPanX = [view userXOffset] * viewSize.width;
		float currentUserPanY = [view userYOffset] * viewSize.height;
		float currentUserScale = [view userScale];
		float currentMapPanX = [view homeXOffset];
		float currentMapPanY = [view homeYOffset];
		float currentMapScaleX = [view homeScaleX];
		float currentMapScaleY = [view homeScaleY];
		float currentScaleX = currentUserScale * currentMapScaleX;
		float currentScaleY = currentUserScale * currentMapScaleY;

		if(fabsf(currentScaleX) < 0.001 || fabsf(scale) < 0.001)
			return;
		if(fabsf(currentScaleY) < 0.001 || fabsf(scale) < 0.001)
			return;

		// Calculate where the centre point is in the untransformed map
		float x_in_map = (x - currentUserPanX - currentMapPanX) / currentScaleX; 
		float y_in_map = (y - currentUserPanY - currentMapPanY) / currentScaleY;

		// Now work out the new scale	
		float newScaleX = currentScaleX * scale;
		float newScaleY = currentScaleY * scale;
		float newUserScale = currentUserScale * scale;

		// Now work out where that point in the map would go now
		float new_x = (x_in_map) * newScaleX + currentMapPanX;
		float new_y = (y_in_map) * newScaleY + currentMapPanY;

		// Andset the user pan to put it back where it was on the screen
		float newPanX = (x - new_x) / viewSize.width ;
		float newPanY = (y - new_y) / viewSize.height;

		[view setUserXOffset:newPanX];
		[view setUserYOffset:newPanY];
		[view setUserScale:newUserScale];
	}
	
}

- (void) adjustPanInView:(PitchView *)view X:(float)x Y:(float)y
{
	CGRect viewBounds = [view bounds];
	CGSize viewSize = viewBounds.size;
	
	if(viewSize.width < 1 || viewSize.height < 1)
		return;
	
	float newPanX = ([view userXOffset] * viewSize.width + x) / viewSize.width;
	float newPanY = ([view userYOffset] * viewSize.height + y)  / viewSize.height;
		
	[view setUserXOffset:newPanX];
	[view setUserYOffset:newPanY];
}

////////////////////////////////////////////////////////////////////////
//


@end

