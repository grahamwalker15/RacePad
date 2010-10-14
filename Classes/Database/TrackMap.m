//
//  TrackMap.m
//  RacePad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TrackMap.h"
#import "RacePadClientSocket.h"
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

- (void) load:(RacePadClientSocket *)socket
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

	pointColour = [[socket PopRGBA] retain];
	x = [socket PopFloat];
	y = [socket PopFloat];
	dotSize = [socket PopInt];
	moving = [socket PopBool];
	
	if ( moving )
	{
		fillColour = [[socket PopRGBA] retain];
		lineColour = [[socket PopRGBA] retain];
		textColour = [[socket PopRGBA] retain];
		
		name = [[socket PopString] retain];
	}
}

- (void) draw:(TrackMapView *)view Scale: (float) scale
{
	CGSize size = [view InqSize];
	float boxWidth = 48;
	float boxHeight = 22;
	
	float px = x * scale;
	float py = size.height - y * scale;
	
	[view SetBGColour:pointColour];
	[view FillRectangleX0:px-dotSize Y0:py-dotSize X1:px+dotSize Y1:py+dotSize];
	
	if ( moving )
	{
		[view SetBGColour:fillColour];
		float x0 = px + 5;
		float y0 = py + 2;
		float x1 = x0 + boxWidth;
		float y1 = y0 - boxHeight;
		[view FillRectangleX0:x0 Y0:y0 X1:x1 Y1:y1];
		
		[view SetLineWidth:2];
		[view SetBGColour:lineColour];
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

- (id) init
{
	[super init];
	x = NULL;
	y = NULL;
	count = 0;
	
	return self;
}

- (void) dealloc
{
	if ( x )
		free ( x );
	if ( y )
		free ( y );
	[super dealloc];
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

-(void) loadShape:(RacePadClientSocket *)socket
{
	count = [socket PopInt];
	x = malloc(sizeof(float) * count);
	y = malloc(sizeof(float) * count);
	
	for (int i = 0; i < count; i++ ) {
		x[i] = [socket PopFloat];
		y[i] = -[socket PopFloat];
	}
	
}

@end

@implementation TrackMap

- (id) init
{
	[super init];
	inner = [[TrackShape alloc] init];
	outer = [[TrackShape alloc] init];
	cars = [[NSMutableArray alloc] init];
	for ( int i = 0; i < 30; i++ )
	{
		TrackCar *car = [[TrackCar alloc]  init];
		[cars addObject:car];
	}
	carCount = 0;
	
	return self;
}

- (void) dealloc
{
	[inner release];
	[outer release];
	[cars release];
	
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

- (void) loadTrack : (RacePadClientSocket *) socket
{
	[inner clear];
	[outer clear];
	int count = [socket PopInt];
	if ( count == 2 )
	{
		[inner loadShape:socket];
		[outer loadShape:socket];
	}
}

- (void) updateCars : (RacePadClientSocket *) socket
{
	carCount = 0;
	
	while (true) {
		int carNum = [socket PopInt];
		if ( carNum < 0 )
			break;
		
		[[cars objectAtIndex:carCount] load:socket];
		carCount++;
	}
}

- (void) drawTrack : (TrackMapView *) view Scale: (float) scale
{
	if ( [inner count] > 1
	  && [outer count] > 1 )
	{
		[view SetLineWidth:2 / scale];
		[view SetFGColour:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
		[view LinePolygonPoints:[inner count] XCoords:[inner x] YCoords:[inner y]];
		
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]];
		[view LinePolygonPoints:[outer count] XCoords:[outer x] YCoords:[outer y]];
	}
}

- (void) drawCars : (TrackMapView *) view Scale: (float) scale
{
	[view UseRegularFont];
	for ( int i = 0; i < carCount; i++ )
		[[cars objectAtIndex:i] draw:view Scale:scale];
}

- (void) draw : (TrackMapView *) view
{
	CGSize size = [view InqSize];
	[view SaveGraphicsState];
	
	float scale;
	if ( size.width < size.height )
		scale = size.width;
	else
		scale = size.height;
	
	scale = scale * 0.9;
	
	[view SetTranslateX:0 Y:size.height];
	[view SetScale:scale];
	
	[self drawTrack:view Scale:scale];
	
	[view RestoreGraphicsState];

	[self drawCars:view Scale:scale];
}



@end

