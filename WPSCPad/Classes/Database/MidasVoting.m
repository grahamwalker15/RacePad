//
//  MidasVoting.m
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasVoting.h"
#import "MidasVotingView.h"

#import "DataStream.h"
#import "RacePadDataHandler.h"

@implementation MidasVoting

@synthesize driver;
@synthesize abbr;
@synthesize votesFor;
@synthesize votesAgainst;
@synthesize position;
@synthesize driverCount;

- (id) init
{
	if(self = [super init])
	{
		driver =nil;
		abbr = nil;
		
		votesFor = 1000;
		votesAgainst = 800;
		position = 5;
		driverCount = 24;
	}	
	return self;
}

- (void) dealloc
{
	[self clearData];
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////

- (void) clearData
{
	[driver release];
	[abbr release];	
	
	driver = nil;
	abbr = nil;
}

- (void) loadData : (DataStream *) stream
{
	[abbr release];	
	
	abbr = [[stream PopString] retain];
	
	votesFor = [stream PopInt];
	votesAgainst = [stream PopInt];
	position = [stream PopInt];
	driverCount = [stream PopInt];
}

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
// Drawing

- (void) drawInView : (MidasVotingView *)view
{
	// Find maximum value
	float maxValue = votesFor > votesAgainst ? votesFor : votesAgainst;
		
	// Make it a minimum of 10s and round up to nearest 5
	if(maxValue < 10.0)
	{
		maxValue = 10.0;
	}
	else
	{
		maxValue = ceilf(maxValue / 5.0) * 5.0;
	}
	
	// Get grid spacing - maximum of 10 lines
	float gridRange = maxValue;
	if(gridRange <= 100.0)
		gridRange = ceilf(gridRange / 10.0) * 10.0;
	else if(gridRange <= 1000.0)
		gridRange = ceilf(gridRange / 100.0) * 100.0;
	else if(gridRange <= 10000.0)
		gridRange = ceilf(gridRange / 1000.0) * 1000.0;
	else if(gridRange <= 100000.0)
		gridRange = ceilf(gridRange / 10000.0) * 10000.0;
	else
		gridRange = ceilf(gridRange / 100000.0) * 100000.0;
	
	float gridSpacing = gridRange / 10.0;
		
	// Now start drawing
	
	CGSize size = [view InqSize];
	
	float ymin = 5;
	float graphicHeight = (size.height - ymin * 2);
	float barWidth = size.width / 5;
	
	// And start drawing...
	
	[view SaveGraphicsState];
	
	float x0, x1, y;
	
	// Draw grid
	[view SetFGColour:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]];
	float yval = 0;
	while ( y < graphicHeight)
	{
		y = yval / maxValue * graphicHeight + ymin;
		[view LineX0:barWidth * 0.5 Y0:size.height - y X1:size.width - barWidth * 0.5 Y1:size.height - y];
		yval += gridSpacing;
	}
	
	// Draw votes for in green
	x0 = barWidth;
	x1 = x0 + barWidth;
	y = (float)votesFor / maxValue * graphicHeight;
	
	[view SetBGColour:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.7]];
	[view SetFGColour:[view white_]];
	
	[view FillShadedRectangleX0:x0 Y0:size.height - ymin X1:x1 Y1:size.height - (ymin+y) WithHighlight:false];
	[view LineRectangleX0:x0 Y0:size.height - ymin X1:x1 Y1:size.height - (ymin+y)];
	
	// Draw votes against in red
	x0 = barWidth * 3;
	x1 = x0 + barWidth;
	y = (float)votesAgainst / maxValue * graphicHeight;
	
	[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.7]];
	[view SetFGColour:[view white_]];
	
	[view FillShadedRectangleX0:x0 Y0:size.height - ymin X1:x1 Y1:size.height - (ymin+y) WithHighlight:false];
	[view LineRectangleX0:x0 Y0:size.height - ymin X1:x1 Y1:size.height - (ymin+y)];
	
	// Draw axes
	[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6]];
	[view LineRectangleX0:barWidth * 0.5 Y0:size.height - ymin X1:size.width - barWidth * 0.5 Y1:size.height - (ymin + graphicHeight)];
		
	[view RestoreGraphicsState];
		
}

@end
