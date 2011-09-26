//
//  PlayerGraph.m
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayerGraph.h"
#import "DataStream.h"
#import "MathOdds.h"
#import "PlayerGraphView.h"
#import "MatchPadDatabase.h"

@implementation PlayerGraphLine

@synthesize path;
@synthesize colour;
@synthesize x0;
@synthesize y0;
@synthesize x1;
@synthesize y1;

- (id) init
{
	if(self = [super init])
	{
		path = nil;
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
}

@end

@implementation PlayerGraph

@synthesize requestedPlayer;
@synthesize graphType;
@synthesize playerName;
@synthesize nextPlayer;
@synthesize prevPlayer;

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
	
	[playerName release];
	
	[super dealloc];
}

- (void) loadGraph : (DataStream *) stream
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
		PitchLine *line = [[PlayerGraphLine alloc] init];
		[line loadShape:stream Count:count Colours:colours ColoursCount:coloursCount];
		[lines addObject:line];
		[line release];
	}
	
	[playerName release];
	playerName = [[stream PopString] retain];
	prevPlayer = [stream PopInt];
	nextPlayer = [stream PopInt];
}

- (void) arrowHead: (PlayerGraphView *) view Line: (PlayerGraphLine *) line Scale: (float) scale
{
	float l = 8 / scale;
	
	double angle = atan2 ( line.y1 - line.y0, line.x1 - line.x0 );
	double a1 = angle + M_PI/8;
	double dx = cos ( a1 ) * l;
	double dy = sin ( a1 ) * l;
	[view LineX0:line.x1 - dx Y0:line.y1 - dy X1:line.x1 Y1:line.y1];
	double a2 = angle - M_PI/8;
	dx = cos ( a2 ) * l;
	dy = sin ( a2 ) * l;
	[view LineX0:line.x1 - dx Y0:line.y1 - dy X1:line.x1 Y1:line.y1];
}

- (void) drawGraph: (PlayerGraphView *) view Scale: (float) scale
{
	[view SaveGraphicsState];
		
	int i;
	// Now draw the other lines
	int count = [lines count];
	for ( i = 0; i < count; i++)
	{
		[view BeginPath];
		PlayerGraphLine *line = [lines objectAtIndex:i];
		[view SetLineWidth:2 / scale];
		[view SetFGColour:[line colour]];
		[view LineX0:line.x0 Y0:line.y0 X1:line.x1 Y1:line.y1];
		if ( graphType == PGV_PASSES )
		{
			[view SetLineWidth:1 / scale];
			[self arrowHead:view Line:line Scale:scale];
		}
	}
	
	[view RestoreGraphicsState];
}

- (void) drawLines: (PlayerGraphView *) view XScale: (float) xScale YScale: (float) yScale XOffset:(float) xOffset YOffset:(float) yOffset
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

- (void) drawInView:(PlayerGraphView *)view
{
	[view SaveGraphicsState];
	
	CGRect map_rect = [view bounds];
	CGSize viewSize = map_rect.size;
	
	float x_scale = viewSize.width - 20;
	float y_scale = viewSize.height - 20;
	
	if ( graphType == PGV_PASSES )
		[self drawLines:view XScale:x_scale YScale:y_scale XOffset:10 YOffset:10];

	[view ResetTransformMatrix];
	
	[view SetTranslateX:10 Y:10];
	[view SetScaleX:x_scale Y:y_scale];
	[view SetTranslateX:-xCentre Y:yCentre];
	
	[view StoreTransformMatrix];	
	
	float scale = x_scale < y_scale ? x_scale : y_scale;
	[self drawGraph:view Scale:scale];
	
	[view RestoreGraphicsState];
	
}

@end

