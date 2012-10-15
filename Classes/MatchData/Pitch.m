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
@synthesize player;
@synthesize playerColour;
@synthesize playerBG;

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
	[player release];
	[playerColour release];
	[playerBG release];
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

-(void) loadShape:(DataStream *)stream Count:(int)count Colours: (UIColor **)colours ColoursCount:(int)coloursCount AllNames:(bool) allNames
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
	
	if ( allNames )
	{
		player = [[stream PopString] retain];
		playerColour = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
		playerBG = [self loadColour:stream Colours:colours ColoursCount:coloursCount];
	}
}

@end

@implementation Pitch

- (id) init
{
	if(self = [super init])
	{
		lines = [[NSMutableArray alloc] init];
		playerNameFont = DW_LIGHT_LARGER_CONTROL_FONT_;
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

- (void) loadPitch : (DataStream *) stream AllNames: (bool) allNames
{
	[lines removeAllObjects];

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
		[line loadShape:stream Count:count Colours:colours ColoursCount:coloursCount AllNames:allNames];
		[lines addObject:line];
		[line release];
	}
	
	[player release];
	player = NULL;
	[playerColour release];
	playerColour = NULL;
	[playerBG release];
	playerBG = NULL;
	[nextPlayer release];
	nextPlayer = NULL;
	[nextPlayerColour release];
	nextPlayerColour = NULL;
	[nextPlayerBG release];
	nextPlayerBG = NULL;
	[third release];
	third = NULL;
	[thirdColour release];
	thirdColour = NULL;
	[thirdBG release];
	thirdBG = NULL;
	
	playerX = [stream PopFloat];
	playerY = 1 - [stream PopFloat];
	player = [[stream PopString] retain];
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		playerColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		playerBG = [colours[index] retain];
	
	nextPlayerX = [stream PopFloat];
	nextPlayerY = 1 - [stream PopFloat];
	nextPlayer = [[stream PopString] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		nextPlayerColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		nextPlayerBG = [colours[index] retain];
	
	thirdX = [stream PopFloat];
	thirdY = 1 - [stream PopFloat];
	third = [[stream PopString] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		thirdColour = [colours[index] retain];
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		thirdBG = [colours[index] retain];
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
			[view viewSpot:[line x0] Y0:[line y0] LineScale:scale];
		}
		else
		{
			if ( [line lineType] == 2 )
				[view SetDashedLine:8.0/scale];
			else
				[view SetSolidLine];
			[view viewLine:[line x0] Y0:[line y0] X1:[line x1] Y1:[line y1]];
		}
	}
	
	[view RestoreGraphicsState];
}

- (void) drawPassesInView:(PitchView *)view AllNames: (bool) allNames Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale
{
	[self drawPasses:view Scale:scale];
}

- (void) drawNamesInView:(PitchView *)view AllNames: (bool) allNames Scale: (float) scale XScale: (float) x_scale YScale:(float) y_scale
{
	if ( allNames )
	{
		int i;
		int count = [lines count];
		NSString *lastName = NULL;
		int lastType = 0;
		for ( i = 0; i < count; i++)
		{
			PitchLine *line = [lines objectAtIndex:i];
			NSString *playerName = [line player];
			if ( playerName
				&& [playerName length]
				&& [line lineType] != 3 )
			{
				bool repeatName = false;
				if ( lastName != NULL
					&& [lastName isEqualToString:playerName] )
					repeatName = true;
				
				if ( !repeatName )
				{
					float x = [line x0];
					float y = [line y0];
					[view transformPoint:&x Y:&y];
					x = x * x_scale + 25;
					y = y * y_scale + 25;
					float sWidth, sHeight;
					[view UseFont:playerNameFont];
					[view GetStringBox:playerName WidthReturn:&sWidth HeightReturn:&sHeight];
					[view SetBGColour:[line playerBG]];
					[view SetAlpha:0.4];
					[view FillRectangleX0:x - 1 Y0:y - 1 X1:x - 1 + sWidth + 2 Y1:y - 1 + sHeight + 2];
					[view SetAlpha:1.0];
					[view DrawString:playerName AtX:x Y:y];
				}
			}
			lastName = playerName;
			lastType = [line lineType];
		}
	}
	else
	{	
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
			[view transformPoint:&x Y:&y];
			x = x * x_scale + 25;
			y = y * y_scale + 25;
			float sWidth, sHeight;
			[view UseFont:playerNameFont];
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
			[view SetFGColour:playerColour];
			[view DrawString:player AtX:x Y:y];
		}
		if ( [nextPlayer length] )
		{
			float x = nextPlayerX;
			float y = nextPlayerY;
			[view transformPoint:&x Y:&y];
			x = x * x_scale + 25;
			y = y * y_scale + 25;
			float sWidth, sHeight;
			[view UseFont:playerNameFont];
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
			[view SetFGColour:nextPlayerColour];
			[view DrawString:nextPlayer AtX:x Y:y];
		}
		if ( [third length] )
		{
			float x = thirdX;
			float y = thirdY;
			[view transformPoint:&x Y:&y];
			x = x * x_scale + 25;
			y = y * y_scale + 25;
			float sWidth, sHeight;
			[view UseFont:playerNameFont];
			[view GetStringBox:third WidthReturn:&sWidth HeightReturn:&sHeight];
			if ( [nextPlayer length] )
			{
				// try to find a place that doesn't overlap
				for ( int i = 0; i < 4; i++ )
				{
					x = thirdX;
					y = thirdY;
					[view transformPoint:&x Y:&y];
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
			[view SetFGColour:thirdColour];
			[view DrawString:third AtX:x Y:y];
		}
	}
}

////////////////////////////////////////////////////////////////////////
//


@end

