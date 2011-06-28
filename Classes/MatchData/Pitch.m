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

@synthesize path;
@synthesize colour;
@synthesize lineType;

- (id) init
{
	if(self = [super init])
	{
		path = nil;
		colour = nil;
	}
	
	return self;
}

- (void) clear
{
	CGPathRelease(path);
	[colour release];
	path = NULL;
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
	float *x = malloc(sizeof(float) * count);
	float *y = malloc(sizeof(float) * count);
	
	int i;
	for ( i = 0; i < count; i++ )
	{
		x[i] = [stream PopFloat];
		y[i] = 1 - [stream PopFloat];
	}
	
	path = [DrawingView CreatePathPoints:count XCoords:x YCoords:y];
	
	free ( x );
	free ( y );

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
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		playerColour = [colours[index] retain];
	
}

- (void) drawLines: (PitchView *) view XScale: (float) xScale YScale: (float) yScale XOffset:(float) xOffset YOffset:(float) yOffset
{
	[view SaveGraphicsState];
	
	[view SetLineWidth:1];
	[view SetFGColour:[view white_]];
	// Edges
	[view LineX0:0 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:1 * yScale + yOffset];
	[view LineX0:0 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:1 * yScale + yOffset];
	[view LineX0:1 * xScale + xOffset Y0:1 * yScale + yOffset X1:1 * xScale + xOffset Y1:0 * yScale + yOffset];
	[view LineX0:1 * xScale + xOffset Y0:0 * yScale + yOffset X1:0 * xScale + xOffset Y1:0 * yScale + yOffset];
	
	// Centre Line
	[view LineX0:0.5 * xScale + xOffset Y0:0 * yScale + yOffset X1:0.5 * xScale + xOffset Y1:1 * yScale + yOffset];
	// Centre Circle
	[view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.085 * xScale];
	[view LineCircle:0.5 * xScale + xOffset Y0:0.5 * yScale + yOffset Radius:0.002 * xScale];
	
	// LH Penalty Area
	[view LineX0:0 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[view LineX0:0.17 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.17 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[view LineX0:0.17 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[view LineArc:0.115 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(45) EndAngle:DegreesToRadians(315) Clockwise:true Radius:0.077 * xScale];
	// LH Goal Area
	[view LineX0:0 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[view LineX0:0.058 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.058 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[view LineX0:0.058 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	// RH Penalty Area
	[view LineX0:1 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.211 * yScale + yOffset];
	[view LineX0:0.83 * xScale + xOffset Y0:0.211 * yScale + yOffset X1:0.83 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[view LineX0:0.83 * xScale + xOffset Y0:0.789 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.789 * yScale + yOffset];
	[view LineArc:0.885 * xScale + xOffset Y0:0.5 * yScale + yOffset StartAngle:DegreesToRadians(135) EndAngle:DegreesToRadians(225) Clockwise:false Radius:0.077 * xScale];
	// RH Goal Area
	[view LineX0:1 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.368 * yScale + yOffset];
	[view LineX0:0.942 * xScale + xOffset Y0:0.368 * yScale + yOffset X1:0.942 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	[view LineX0:0.942 * xScale + xOffset Y0:0.632 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.632 * yScale + yOffset];
	
	[view SetLineWidth:2];
	// LH Goal
	[view LineX0:0 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:0 * xScale + xOffset Y1:0.558 * yScale + yOffset];

	// RH Goal
	[view LineX0:1 * xScale + xOffset Y0:0.442 * yScale + yOffset X1:1 * xScale + xOffset Y1:0.558 * yScale + yOffset];
	
	[view RestoreGraphicsState];
}

- (void) drawPitch: (PitchView *) view Scale: (float) scale
{
	[view SaveGraphicsState];
		
	int i;
	// Now draw the other lines
	int count = [lines count];
	for ( i = 0; i < count; i++)
	{
		[view BeginPath];
		PitchLine *line = [lines objectAtIndex:i];
		[view LoadPath:[line path]];
		[view SetLineWidth:2 / scale];
		[view SetFGColour:[line colour]];
		if ( [line lineType] == 2 )
			[view SetDashedLine:5.0/scale];
		else
			[view SetSolidLine];
		[view LineCurrentPath];
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
	// The pitch is inset 10 pixels all round
	float x_scale = viewSize.width - 20;
	float y_scale = viewSize.height - 20;
	
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
	mapXOffset = 10;
	mapYOffset = 10;
	
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
	
	// Draw pitch outline in un-scaled space - because of the circles!
	[self drawLines:view XScale:x_scale YScale:y_scale XOffset:xOffset YOffset:yOffset];
	
	[self constructTransformMatrixForView:view];
	
	float scale = x_scale < y_scale ? x_scale : y_scale;
	[self drawPitch:view Scale:scale];
	
	[view RestoreGraphicsState];

	if ( [player length] )
	{
		[view UseRegularFont];
		[view SetFGColour:playerColour];
		[view DrawString:player AtX:playerX * x_scale + 10 Y:playerY * y_scale + 10];
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

