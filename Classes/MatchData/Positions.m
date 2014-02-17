//
//  Positions.m
//  MatchPad
//
//  Created by Mark Riches on August 2012
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Positions.h"
#import "DataStream.h"
#import "PitchView.h"
#import "MathOdds.h"
#import "ImageListStore.h"
#import "MatchPadDatabase.h"

@implementation TrailPoint

@synthesize opacity;
@synthesize x;
@synthesize y;

- (id) init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end

@implementation Position

@synthesize team;
@synthesize player;
@synthesize x;
@synthesize y;
@synthesize trail;

- (id) init
{
	if(self = [super init])
	{
		x = 0;
		y = 0;
		team = 0;
		player = 0;
		trail = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[trail release];
	[super dealloc];
}

-(void) loadPosition:(DataStream *)stream Team:(unsigned char)in_team
{
	team = in_team;
	player = [stream PopUnsignedChar];
	x = [stream PopFloat];
	y = 1 - [stream PopFloat];
	
	while ( true )
	{
		unsigned char opacity;
		opacity = [stream PopUnsignedChar];
		if ( opacity == 0 )
			break;
		
		TrailPoint *p = [[TrailPoint alloc] init];
		p.opacity = opacity;
		p.x = [stream PopFloat];
		p.y = 1 - [stream PopFloat];
		
		[trail addObject:p];
	}
}

@end

@implementation Positions

@synthesize ballX;
@synthesize ballY;

- (id) init
{
	if(self = [super init])
	{
		positions = [[NSMutableArray alloc] init];
		teamColour[0] = [DrawingView CreateColourRed:5 Green:100 Blue:170];
		teamColour[1] = [DrawingView CreateColourRed:255 Green:255 Blue:255];
		teamColour[2] = [DrawingView CreateColourRed:255 Green:50 Blue:50];
		teamColour[3] = [DrawingView CreateColourRed:50 Green:50 Blue:255];
		teamColour[4] = [DrawingView CreateColourRed:50 Green:50 Blue:50];
		ballTrail = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[positions release];
	[ballTrail release];

	for ( int i = 0; i < 5; i++ )
		[teamColour[i] release];
	
	[super dealloc];
}

- (void) loadPositions : (DataStream *) stream
{
	[positions removeAllObjects];

	ballX = [stream PopFloat];
	ballY = 1 - [stream PopFloat];
	
	[ballTrail removeAllObjects];

	while ( true )
	{
		unsigned char opacity;
		opacity = [stream PopUnsignedChar];
		if ( opacity == 0 )
			break;
		
		TrailPoint *p = [[TrailPoint alloc] init];
		p.opacity = opacity;
		p.x = [stream PopFloat];
		p.y = 1 - [stream PopFloat];
		
		[ballTrail addObject:p];
	}

	while ( true )
	{
		unsigned char team = [stream PopUnsignedChar];
		if ( team == 0 )
			break;
		Position *p = [[Position alloc] init];
		[p loadPosition:stream Team:team];
		[positions addObject:p];
		[p release];
	}
}

- (void) drawBallTrailInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale
{
	int t_count = ballTrail.count;
	if ( t_count > 1 )
	{
		[view SetFGColour:[view red_]];
		[view SetAlpha:1.0];
		[view SetLineWidth:3];
		TrailPoint *t = [ballTrail objectAtIndex:0];
		
		float x0 = t.x;
		float y0 = t.y;
		[view transformPoint:&x0 Y:&y0];
		x0 = x0 * x_scale + 25;
		y0 = y0 * y_scale + 25;
		for ( int ti = 1; ti < t_count; ti++ )
		{
			TrailPoint *t = [ballTrail objectAtIndex:ti];
			
			float x1 = t.x;
			float y1 = t.y;
			[view transformPoint:&x1 Y:&y1];
			x1 = x1 * x_scale + 25;
			y1 = y1 * y_scale + 25;
			[view SetAlpha:t.opacity/255.0f];
			[view LineX0:x0 Y0:y0 X1:x1 Y1:y1];
			x0 = x1;
			y0 = y1;
		}
	}
}

- (void) drawTrailsInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale
{
	int i;
	int count = [positions count];
	
	// Draw the trails first
	for ( i = 0; i < count; i++)
	{
		Position *p = [positions objectAtIndex:i];
		int t_count = p.trail.count;
		if ( t_count > 1 )
		{
			[view SetFGColour:teamColour[p.team-1]];
			[view SetAlpha:1.0];
			[view SetLineWidth:3];
			TrailPoint *t = [p.trail objectAtIndex:0];
			
			float x0 = t.x;
			float y0 = t.y;
			[view transformPoint:&x0 Y:&y0];
			x0 = x0 * x_scale + 25;
			y0 = y0 * y_scale + 25;
			for ( int ti = 1; ti < t_count; ti++ )
			{
				TrailPoint *t = [p.trail objectAtIndex:ti];
				
				float x1 = t.x;
				float y1 = t.y;
				[view transformPoint:&x1 Y:&y1];
				x1 = x1 * x_scale + 25;
				y1 = y1 * y_scale + 25;
				[view SetAlpha:t.opacity/255.0f];
				[view LineX0:x0 Y0:y0 X1:x1 Y1:y1];
				x0 = x1;
				y0 = y1;
			}
		}
	}
}

- (void) drawPlayersInView:(PitchView *)view Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale
{
	[view SaveFont];
	[view UseControlFont];
	
	int i;
	int count = [positions count];
		
	// Now draw the players
	for ( i = 0; i < count; i++)
	{
		Position *p = [positions objectAtIndex:i];
		float x = [p x];
		float y = [p y];
		[view transformPoint:&x Y:&y];
		x = x * x_scale + 25;
		y = y * y_scale + 25;
		float sWidth, sHeight;
		NSString *playerName;
		
		if ( p.team == 5 )
		{
			if ( p.player == 3 )
				playerName = @"R";
			else
				playerName = @"A";
		}
		else
		{
			playerName = [NSString stringWithFormat:@"%d", p.player];
		}
		
		[view GetStringBox:playerName WidthReturn:&sWidth HeightReturn:&sHeight];
		
		if ( p.team == 5 )
		{
			[view SetBGColour:teamColour[p.team-1]];
			[view SetAlpha:0.4];
			x -= sWidth / 2;
			y -= sHeight / 2;
			[view FillRectangleX0:x - sWidth / 2 - 1 Y0:y - sHeight / 2 - 1 X1:x + sWidth / 2 + 1 Y1:y + sHeight / 2 + 1];
			[view SetAlpha:1.0];
			[view SetFGColour:[view white_]];
		}
		else if ( p.team == 1 )
		{
			UIImage * image = [UIImage imageNamed:@"PlayerLightBlue.png"];
			[image drawAtPoint:CGPointMake(x - 10, y - 10)];
			[view SetFGColour:[view black_]];
		}
		else if ( p.team == 2 )
		{
			UIImage * image = [UIImage imageNamed:@"PlayerBlack.png"];
			[image drawAtPoint:CGPointMake(x - 10, y - 10)];
			[view SetFGColour:[view white_]];
		}
	
		[view DrawString:playerName AtX:x - sWidth / 2 Y:y - sHeight / 2];
	}
	
	[view RestoreFont];
	
	float bx = ballX;
	float by = ballY;
	[view transformPoint:&bx Y:&by];
	bx = bx * x_scale + 25;
	by = by * y_scale + 25;
	UIImage * image = [UIImage imageNamed:@"Ball.png"];
	[image drawAtPoint:CGPointMake(bx - 8, by - 8)];
	[view SetFGColour:[view white_]];
}

////////////////////////////////////////////////////////////////////////
//


@end

