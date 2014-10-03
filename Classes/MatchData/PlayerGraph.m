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
		PlayerGraphLine *line = [[PlayerGraphLine alloc] init];
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
	long count = [lines count];
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

- (void) drawAxes: (PlayerGraphView *) view XScale: (float) xScale YScale: (float) yScale XOffset:(float) xOffset YOffset:(float) yOffset
{
	CGSize size = [view InqSize];
	
	float xAxisSpace = yOffset;
	float yAxisSpace = xOffset;
	float graphicWidth = size.width - yAxisSpace;
	float graphicHeight = (size.height - xAxisSpace * 2);
	int x_axis = size.height - xAxisSpace;
	
	// And start drawing...
	
	[view SaveGraphicsState];
	[view SaveFont];
	
	// Draw Y Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	[view FillRectangleX0:yAxisSpace - 2 Y0:0 X1:yAxisSpace Y1:x_axis];
	//[view FillRectangleX0:size.width - yAxisSpace Y0:0 X1:size.width - yAxisSpace + 2 Y1:size.height];
	
	// Add tick marks every 2% with labels every 10%
	
	[view UseRegularFont];
	
	for ( int yval = 2; yval <= 100; yval += 2 )
	{
		double y = x_axis - (float)yval * 0.01 * graphicHeight;
		
		if ((yval % 10) == 0 )
		{
			[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
			[view LineRectangleX0:yAxisSpace Y0:y X1:size.width - yAxisSpace + 5 Y1:y]; 
			
			[view SetFGColour:[view white_]];
			[view LineRectangleX0:yAxisSpace - 5 Y0:y X1:yAxisSpace Y1:y]; 
			
			NSNumber *n = [NSNumber numberWithInt:yval];
			NSString *s = [n stringValue];
			s = [s stringByAppendingString:@"%"];
			float w, h;
			[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
			[view DrawString:s AtX:yAxisSpace - w - 8 Y:y - h/2];
		}
		else
		{
			[view SetFGColour:[view white_]];
			[view LineRectangleX0:yAxisSpace - 4 Y0:y X1:yAxisSpace Y1:y]; 
		}
	}
	
	// Draw X Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	
	[view FillRectangleX0:yAxisSpace Y0:x_axis X1:yAxisSpace + graphicWidth Y1:x_axis+2];
	
	// Add tick marks every minute with labels every 5
	[view UseMediumBoldFont];
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	
	for ( int m = 1; m <= 50; m++ )
	{			
		float xval = (float)m / (float)50 * graphicWidth + yAxisSpace;
		
		if ((m % 5) == 0 && m <= 45)
		{
			[view LineRectangleX0:xval Y0:x_axis X1:xval Y1:x_axis + 5]; 
			
			NSNumber *n = [NSNumber numberWithInt:m];
			NSString *s = [NSString stringWithString:[n stringValue]];
			s = [s stringByAppendingString:@"m"];

			float w, h;
			[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
			[view DrawString:s AtX:xval - w / 2 Y:x_axis + 4];
		}
		else
		{
			[view LineRectangleX0:xval Y0:x_axis X1:xval Y1:x_axis + 3]; 
		}		
	}
	
	[view RestoreFont];	
	[view RestoreGraphicsState];
	
}

- (void) drawInView:(PlayerGraphView *)view
{
	[view SaveGraphicsState];
	
	CGRect map_rect = [view bounds];
	CGSize viewSize = map_rect.size;
	
	float xOffset, yOffset;
	float xScale, yScale;
	
	if ( graphType == PGV_PASSES )
	{
		xOffset = 10;
		yOffset = 10;
		xScale = viewSize.width - xOffset * 2;
		yScale = viewSize.height - yOffset * 2;
		[self drawLines:view XScale:xScale YScale:yScale XOffset:xOffset YOffset:yOffset];
	}
	else if ( graphType == PGV_EFFECTIVENESS)
	{
		xOffset = 60;
		yOffset = 25;
		xScale = viewSize.width - xOffset * 2;
		yScale = viewSize.height - yOffset * 2;
		[self drawAxes:view XScale:xScale YScale:yScale XOffset:xOffset YOffset:yOffset];
	}

	[view ResetTransformMatrix];
	
	[view SetTranslateX:xOffset Y:yOffset];
	[view SetScaleX:xScale Y:yScale];
	[view SetTranslateX:-xCentre Y:yCentre];
	
	[view StoreTransformMatrix];	
	
	float scale = xScale < yScale ? xScale : yScale;
	[self drawGraph:view Scale:scale];
	
	[view RestoreGraphicsState];
	
}

@end

