//
//  TeamStats.m
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TeamStats.h"
#import "DataStream.h"
#import "MathOdds.h"
#import "TeamStatsView.h"
#import "MatchPadDatabase.h"

@implementation TeamStat

@synthesize name;
@synthesize type;
@synthesize home;
@synthesize away;

- (id) init
{
	if(self = [super init])
	{
		name = nil;
		type = TS_BAR_CHART;
		home = 0;
		away = 0;
	}
	
	return self;
}

- (void) clear
{
	[name release];
}

- (void) dealloc
{
	[self clear];
	
	[super dealloc];
}

-(void) loadStat:(DataStream *)stream
{
	name = [[stream PopString] retain];
	type = [stream PopUnsignedChar];
	home = [stream PopInt];
	away = [stream PopInt];
}

@end

@implementation TeamStats

@synthesize home;
@synthesize away;
@synthesize homeColour;
@synthesize awayColour;

- (id) init
{
	if(self = [super init])
	{
		stats = [[NSMutableArray alloc] init];
		home = nil;
		away = nil;
		homeColour = nil;
		awayColour = nil;
	}
	
	return self;
}

- (void) dealloc
{
	[stats release];
	
	[home release];
	[away release];
	[homeColour release];
	[awayColour release];
	
	[super dealloc];
}

- (void) loadStats : (DataStream *) stream
{
	[stats removeAllObjects];

	[home release];
	[away release];
	[homeColour release];
	[awayColour release];

	home = [[stream PopString] retain];
	homeColour = [[stream PopRGBA] retain];
	away = [[stream PopString] retain];
	awayColour = [[stream PopRGBA] retain];
		
	int count = [stream PopInt];
	for ( int i = 0; i < count; i++ )
	{
		TeamStat *stat = [[TeamStat alloc] init];
		[stat loadStat:stream];
		[stats addObject:stat];
		[stat release];
	}
}

- (void) drawBarChart:(TeamStatsView *)view Y:(int) y
					Name:(NSString *) name
					Home:(int) homeV
					Away:(int) awayV
{
	CGRect view_rect = [view bounds];
	CGSize viewSize = view_rect.size;
	
	int margin = 75;
	float width, height;
	[view GetStringBox:name WidthReturn:&width HeightReturn:&height];
	[view DrawString:name AtX:(viewSize.width - width) / 2 Y:y];
	y += height + 2;
	int total = homeV + awayV;
	if ( total )
	{
		if ( homeV )
		{
			[view SetBGColour:homeColour];
			float bar = (viewSize.width - 2 - margin * 2) / (float)total * homeV;
			[view FillShadedRectangleX0:margin Y0:y X1:margin + bar - 1 Y1: y + height - 1 WithHighlight:true];
		}
		if ( awayV )
		{
			[view SetBGColour:awayColour];
			float bar = (viewSize.width - 2 - margin * 2) / (float)total * awayV;
			[view FillShadedRectangleX0:viewSize.width - margin - bar + 1 Y0:y X1:viewSize.width - margin Y1: y + height - 1 WithHighlight:true];
		}
	}
	NSNumber *v = [NSNumber numberWithInt:homeV];
	NSString *s = [v stringValue];
	[view GetStringBox:s WidthReturn:&width HeightReturn:&height];
	[view DrawString:s AtX:margin - 2 - width Y:y];
	v = [NSNumber numberWithInt:awayV];
	s = [v stringValue];
	[view DrawString:s AtX:viewSize.width - margin + 2 Y:y];
}

- (void) drawPieChart:(TeamStatsView *)view Y:(int) y
				 Name:(NSString *) name
				 Home:(int) homeV
				 Away:(int) awayV
{
	CGRect view_rect = [view bounds];
	CGSize viewSize = view_rect.size;
	
	int margin = 75;
	float width, height;
	[view GetStringBox:name WidthReturn:&width HeightReturn:&height];
	[view DrawString:name AtX:(viewSize.width - width) / 2 Y:y];
	y += height + 2;
	int total = homeV + awayV;
	if ( total )
	{
		// Note clockwise and anti-clockwise are not what you would expect
		// because the defaut transformation matrix is flipping Y
		if ( homeV )
		{
			[view SetBGColour:homeColour];
			float seg = 270 - 360 / (float)total * homeV;
			[view FillArc:viewSize.width / 2 Y0:y + 50 StartAngle:DegreesToRadians(270) EndAngle:DegreesToRadians(seg) Clockwise:true Radius:45];
		}
		if ( awayV )
		{
			[view SetBGColour:awayColour];
			float seg = 270 + 360 / (float)total * awayV;
			[view FillArc:viewSize.width / 2 Y0:y + 50 StartAngle:DegreesToRadians(270) EndAngle:DegreesToRadians(seg) Clockwise:false Radius:45];
		}
	}
	NSNumber *v = [NSNumber numberWithInt:homeV];
	NSString *s = [v stringValue];
	[view GetStringBox:s WidthReturn:&width HeightReturn:&height];
	[view DrawString:s AtX:margin - 2 - width Y:y];
	v = [NSNumber numberWithInt:awayV];
	s = [v stringValue];
	[view DrawString:s AtX:viewSize.width - margin + 2 Y:y];
}

- (void) drawInView:(TeamStatsView *)view
{
	[view SaveGraphicsState];
	
	CGRect view_rect = [view bounds];
	CGSize viewSize = view_rect.size;
	
	int x = 50;
	int y = 10;
	for ( int i = 0; i < [stats count]; i++ )
	{
		TeamStat *stat = [stats objectAtIndex:i];
		if ( stat.type == TS_BAR_CHART )
		{
			[self drawBarChart: view Y:y Name:stat.name Home:stat.home Away:stat.away];
			y += 60;
		}
		else
		{
			[self drawPieChart: view Y:y Name:stat.name Home:stat.home Away:stat.away];
			y += 120;
		}
	}
	[view SetFGColour:homeColour];
	[view DrawString:home AtX:20 Y:y];
	float width, height;
	[view GetStringBox:away WidthReturn:&width HeightReturn:&height];
	[view SetFGColour:awayColour];
	[view DrawString:away AtX:viewSize.width - 20 - width Y:y];
	[view RestoreGraphicsState];
	
}

@end

