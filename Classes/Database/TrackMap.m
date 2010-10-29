//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackMap.h"
#import "DataStream.h"
#import "TrackMapView.h"

@implementation TrackCar

- (id) init
{
	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	
	name = nil;
	
	return [super init];
}

- (void) dealloc
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];
	
	[super dealloc];
}

- (UIColor *) loadColour: (DataStream *)stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		return [colours[index] retain];
	
	return nil;
}

- (void) load:(DataStream *)stream Colours: (UIColor **)colours ColoursCount:(int)coloursCount
{
	[pointColour release];
	[fillColour release];
	[lineColour release];
	[textColour release];
	[name release];

	pointColour = nil;
	fillColour = nil;
	lineColour = nil;
	textColour = nil;
	name = nil;


	pointColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	x = [stream PopFloat];
	y = -[stream PopFloat];
	dotSize = [stream PopInt];
	moving = [stream PopBool];
	
	if ( moving )
	{
		fillColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		lineColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		textColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		
		name = [[stream PopString] retain];
	}
}

- (void) draw:(TrackMapView *)view Scale:(float)scale
{
	CGSize size = [view bounds].size;
	
	float boxWidth = 48;
	float boxHeight = 22;
	
	CGPoint p = CGPointMake(x, y);
	CGPoint tp = [view TransformPoint:p];
	
	float px = tp.x;
	float py = size.height - tp.y;
	
	[view SetBGColour:pointColour];
	[view FillRectangleX0:px-dotSize Y0:py-dotSize X1:px+dotSize Y1:py+dotSize];
	
	if ( moving )
	{
		float x0 = px + 5;
		float y0 = py + 2;
		float x1 = x0 + boxWidth;
		float y1 = y0 - boxHeight;
		
		// Shadow
		[view SetBGToShadowColour];		
		[view FillRectangleX0:x0+5 Y0:y0+5 X1:x1+5 Y1:y1+5];

		// Box
		[view SetBGColour:fillColour];
		[view FillRectangleX0:x0 Y0:y0 X1:x1 Y1:y1];
		
		[view SetLineWidth:2];
		[view SetFGColour:lineColour];
		[view LineRectangleX0:x0 Y0:y0 X1:x1 Y1:y1];
		
		if ( name != nil )
		{
			[view SetFGColour:textColour];
			[view DrawString:name AtX:px + 7 Y:py - 20];
		}
	}
}

@end


@implementation TrackShape

@synthesize width;
@synthesize height;
@synthesize min_x;
@synthesize max_x;
@synthesize min_y;
@synthesize max_y;
@synthesize path;
@synthesize segmentCount;
@synthesize segmentPaths;

- (id) init
{
	if(self = [super init])
	{
		x = NULL;
		y = NULL;
		path = nil;
		count = 0;
		
		min_x = 0.0;
		max_x = 0.0;
		min_y = 0.0;
		max_y = 0.0;

		width = 0.0;
		height = 0.0;
	}
	
	return self;
}

- (void) clear
{
	if ( x )
		free ( x );
	x = NULL;
	
	if ( y )
		free ( y );
	y = NULL;
	
	count = 0;
	
	CGPathRelease(path);
	path = NULL;
	
	segmentCount = 0;
	int i;
	if ( segmentPaths )
	{
		for ( i = 0; i < segmentCount; i++ )
			CGPathRelease(segmentPaths[i]);
		free (segmentPaths);
	}
	
	segmentPaths = NULL;
	
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

- (int) count
{
	return count;
}

- (float *) x
{
	return x;
}

- (float *) y
{
	return y;
}

-(void) loadShape:(DataStream *)stream
{
	// Assume we've been cleared
	
	count = [stream PopInt];
	x = malloc(sizeof(float) * count);
	y = malloc(sizeof(float) * count);
	
	min_x = 1.0;
	max_x = 0.0;
	min_y = 1.0;
	max_y = 0.0;
	
	width = 0.0;
	height = 0.0;
	
	int i;
	for ( i = 0; i < count; i++ )
	{
		x[i] = [stream PopFloat];
		y[i] = -[stream PopFloat];
		
		if(x[i] > max_x)
			max_x = x[i];
		
		if(x[i] < min_x)
			min_x = x[i];
		
		if(-y[i] > max_y)
			max_y = -y[i];
		
		if(-y[i] < min_y)
			min_y = -y[i];
		
	}
	
	width = max_x - min_x;
	height = max_y - min_y;
	
	path = [DrawingView CreatePathPoints:count XCoords:x YCoords:y];
	
	segmentCount = [stream PopInt];
	
	if ( segmentCount )
	{
		int *segments = malloc ( segmentCount * sizeof ( int ) );
		for ( i = 0; i < segmentCount; i++ )
			segments[i] = [stream PopInt];
		
		segmentPaths = malloc ( sizeof (CGMutablePathRef) * segmentCount );
		for ( i = 0; i < segmentCount; i++ )
		{
			int p0 = segments[i];
			int p1;
			if ( i < segmentCount - 1 )
				p1 = segments[i+1];
			else
				p1 = segments[0];
			
			segmentPaths[i] = [DrawingView CreatePathPoints:p0 P1:p1 XCoords:x YCoords:y Count:count];
		}
		
		free ( segments );
	}
}

@end

@implementation SegmentState

@synthesize index;
@synthesize state;

- (id) init: (int) inIndex State: (unsigned char)inState
{
	if ( [super init] == self )
	{
		index = inIndex;
		state = inState;
	}
	
	return self;
}

@end


@implementation TrackMap

- (id) init
{
	if(self = [super init])
	{
		inner = [[TrackShape alloc] init];
		outer = [[TrackShape alloc] init];
		cars = [[NSMutableArray alloc] init];
		
		for ( int i = 0; i < 40; i++ )
		{
			TrackCar *car = [[TrackCar alloc]  init];
			[cars addObject:car];
		}
		
		carCount = 0;
		
		segmentStates = [[NSMutableArray arrayWithCapacity:30] retain];
		
		x_centre = 0.0;
		y_centre = 0.0;
		
		width = 0.0;
		height = 0.0;
	}
	
	return self;
}

- (void) dealloc
{
	[inner release];
	[outer release];
	[cars release];
	[segmentStates removeAllObjects];
	[segmentStates release];

	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	[super dealloc];
}

- (TrackShape *)inner
{
	return inner;
}

- (TrackShape *)outer
{
	return outer;
}

- (void) loadTrack : (DataStream *) stream
{
	[inner clear];
	[outer clear];
	
	width = 0.0;
	height = 0.0;
	
	x_centre = 0.0;
	y_centre = 0.0;
	
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
	for ( c = 0; c < coloursCount; c++ ) {
		unsigned char index = [stream PopUnsignedChar];
		UIColor *colour = [[stream PopRGBA] retain];
		if ( index < coloursCount )
			colours[index] = colour;
		else
			[colour release];
	}
	
	int count = [stream PopInt];

	if ( count == 2 )
	{
		[inner loadShape:stream];
		[outer loadShape:stream];
	}
	
	width = [inner width] > [outer width] ? [inner width] : [outer width];
	height = [inner height] > [outer height] ? [inner height] : [outer height];
	
	float min_x = [inner min_x] < [outer min_x] ? [inner min_x] : [outer min_x];
	float min_y = [inner min_y] < [outer min_y] ? [inner min_y] : [outer min_y];
	float max_x = [inner max_x] > [outer max_x] ? [inner max_x] : [outer max_x];
	float max_y = [inner max_y] > [outer max_y] ? [inner max_y] : [outer max_y];
	
	x_centre = (min_x + max_x) * 0.5;
	y_centre = (min_y + max_y) * 0.5;
	
}

- (void) updateCars : (DataStream *) stream
{
	carCount = 0;
	
	while (true)
	{
		int carNum = [stream PopInt];
		if ( carNum < 0 )
			break;
		
		[[cars objectAtIndex:carCount] load:stream Colours:colours ColoursCount:coloursCount];
		carCount++;
	}
	
	[segmentStates removeAllObjects];
	while (true)
	{
		int segNum = [stream PopInt];
		if ( segNum < 0 )
			break;
		
		unsigned char state = [stream PopUnsignedChar];
		[segmentStates addObject:[[SegmentState alloc] init:segNum State:state]];
	}
}

- (void) drawTrack : (TrackMapView *) view Scale: (float) scale
{
	if ( [inner path]  && [outer path] )
	{
		// Draw inner and outer track in 2 point white with drop shadow
		[view SaveGraphicsState];
		
		[view SetLineWidth:2 / scale];
		[view SetDropShadowXOffset:5.0 YOffset:5.0 Blur:0.0];
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
		
		[view BeginPath];
		[view LoadPath:[inner path]];
		[view LoadPath:[outer path]];
		[view LinePath];
		
		// Now overlay any red/yellow segments
		int count = [segmentStates count];
		for (int i = 0; i < count; i++)
		{
			[view BeginPath];
			int index = [[segmentStates objectAtIndex:i] index];
			if ( index < [inner segmentCount] )
				[view LoadPath:[inner segmentPaths][index]];
			if ( index < [outer segmentCount] )
				[view LoadPath:[outer segmentPaths][index]];
			if ( [[segmentStates objectAtIndex:i] state] == 1 )
				[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
			else
				[view SetFGColour:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
			[view LinePath];
		}
		
		[view RestoreGraphicsState];
	}
}

- (void) drawCars : (TrackMapView *) view Scale:(float)scale
{
	[view UseRegularFont];
	
	for ( int i = 0; i < carCount; i++ )
		[[cars objectAtIndex:i] draw:view Scale:scale];
}

- (void) draw : (TrackMapView *) view
{
	// Get dimensions of current view
	CGRect bounds = [view bounds];
	
	// Map is drawn within a reduced rectangle in this view
	CGRect map_rect = CGRectInset(bounds, 30, 30);
	
	CGPoint origin = map_rect.origin;
	CGSize size = map_rect.size;
	
	[view SaveGraphicsState];
	
	// Centre the map as big as possible in the rectangle
	float x_scale = (width > 0.0) ? size.width / width : size.width;
	float y_scale = (height > 0.0) ? size.height / height : size.height;
	
	float scale = (x_scale < y_scale) ? x_scale : y_scale;
	
	scale = scale * 0.9;
	
	float x_top_left = origin.x + size.width * 0.5 - x_centre * scale  ;
	float y_top_left = bounds.size.height - (origin.y + size.height * 0.5 - y_centre * scale)  ;
	
	[view SetTranslateX:x_top_left Y:y_top_left];
	[view SetScale:scale];
	
	[self drawTrack:view Scale:scale];
	
	[view StoreTransformMatrix];
	
	[view RestoreGraphicsState];
	
	[self drawCars:view Scale:scale];

}

@end

