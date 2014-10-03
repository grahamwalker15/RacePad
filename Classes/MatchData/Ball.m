//
//  Ball.m
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "Ball.h"
#import "BallView.h"
#import "DataStream.h"
#import "MatchPadDataHandler.h"
#import "MatchPadDatabase.h"

@implementation BallChunk

@synthesize time;
@synthesize position;
@synthesize newMove;

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

- (void) load : (DataStream *) stream
{
	time = [stream PopFloat];
	position = [stream PopFloat];
	newMove = [stream PopBool];
}

@end	

@implementation Ball

- (id) init
{
	if(self = [super init])
	{
		kicks[0]  = [[NSMutableArray alloc] init];
		kicks[1]  = [[NSMutableArray alloc] init];
		goals[0]  = [[NSMutableArray alloc] init];
		goals[1]  = [[NSMutableArray alloc] init];
	}	
	return self;
}

- (void) dealloc
{
	[self clearData];
	[kicks[0] release];
	[kicks[1] release];
	[goals[0] release];
	[goals[1] release];
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////

- (void) clearData
{
	[kicks[0] removeAllObjects];
	[kicks[1] removeAllObjects];
	[goals[0] removeAllObjects];
	[goals[1] removeAllObjects];
}

- (void) loadData : (DataStream *) stream
{
	[self clearData];
	
	int i;
	
	for ( i = 0; i < 2; i++ )
	{
		int count = [stream PopInt];
		for ( int j = 0; j < count; j++ )
		{
			BallChunk *chunk = [[BallChunk alloc] init];
			[chunk load:stream];
			[kicks[i] addObject:chunk];
		}
		
		duration[i] = [stream PopFloat];
		
		while ( true )
		{
			float g = [stream PopFloat];
			if ( g == 0 )
				break;
			else
			{
				NSNumber *n = [NSNumber numberWithFloat:g];
				[goals[i] addObject:n];
			}
		}
	}
}

- (void) clearStaticData
{
	[self clearData];
}

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
// Drawing

- (void) drawInView : (BallView *)view
{
	// Now start drawing
	
	CGSize size = [view InqSize];
	
	float xAxisSpace = 25;
	float yAxisSpace = 50;
	float halfTimeSpace = 25;
	float graphicWidth = size.width - yAxisSpace;
	float graphicHeight = (size.height - xAxisSpace * 3 - 50 - 70) * 0.5;
	int x_axis = size.height * 0.5 - xAxisSpace * 0.5 + [view yOffset];
		
	CGMutablePathRef drawingArea = [DrawingView CreateRectPathX0:0 Y0:0 X1:graphicWidth Y1:size.height];
	
	// Work out width of a column, and thereby what content we can draw
	float secWidth = ([view transformX:1.0 / (duration[0] + duration[1])] - [view transformX:0.0]) * (graphicWidth - halfTimeSpace);
	
	// And start drawing...
	
	[view SaveGraphicsState];
	[view SaveFont];
	
	// Draw Titles
	[view SetFGColour:[view white_]];
	[view UseBigFont];
	NSString *homeTeam = [[MatchPadDatabase Instance]homeTeam];
	float w, h;
	[view GetStringBox:homeTeam WidthReturn:&w HeightReturn:&h];
	[view DrawString:homeTeam AtX:(size.width - w) * 0.5 Y:x_axis - graphicHeight - xAxisSpace - h - 2 ];
	
	NSString *awayTeam = [[MatchPadDatabase Instance]awayTeam];
	[view GetStringBox:awayTeam WidthReturn:&w HeightReturn:&h];
	[view DrawString:awayTeam AtX:(size.width - w) * 0.5 Y:x_axis + xAxisSpace + graphicHeight + xAxisSpace + 2 ];
	
	
	// Draw Y Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	[view FillRectangleX0:size.width - yAxisSpace Y0:0 X1:size.width - yAxisSpace + 2 Y1:size.height];
	
	// Add tick marks every pass
	[view UseMediumBoldFont];
	
	/*
	for ( int yval = 5; yval <= maxPasses; yval += 5 )
	{
		double yTop = x_axis - (float)yval / maxPasses * graphicHeight;
		double yBot = x_axis + xAxisSpace + (float)yval / maxPasses * graphicHeight;
		
		[view SetLineWidth:0.5];
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
		[view LineX0:0 Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
		[view LineX0:0 Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 

		[view SetFGColour:[view white_]];
		[view SetLineWidth:1.5];
		[view LineX0:size.width - yAxisSpace Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
		[view LineX0:size.width - yAxisSpace Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 
		
		NSNumber *n = [NSNumber numberWithInt:yval];
		NSString *s = [n stringValue];
		float w, h;
		[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
		[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yTop - h/2];
		[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yBot - h/2];
	}
	 */
	
	// Set clipping area for the rest - to exclude y axis
	// Restored with graphic state at the end
	[view SetClippingAreaToPath:drawingArea];
	
	float x1 = [view transformX:0] * graphicWidth;
	int home = 0;
	int away = 0;
	for ( int p = 0; p < 2; p++ )
	{
		[view SetLineWidth:1];
		float baseX = x1;

		// Draw the Time Axis
		for( int s = 0; s < duration[p]; )
		{
			int s1;
			if ( s == 0 )
			{
				s1 = s + 5 * 60;
			}
			else
			{
				s1 = s + 10 * 60;
				if ( s1 > duration[p] )
					s1 = duration[p];
			}
			
			float x1 = baseX + s * secWidth;
			float x2 = baseX + s1 * secWidth;

			[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
			[view SetBGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
			[view FillShadedRectangleX0:x1 Y0:x_axis X1:x2 Y1:x_axis + xAxisSpace WithHighlight:false];
			[view LineRectangleX0:x1 Y0:x_axis X1:x2 Y1:x_axis + xAxisSpace]; 
			
			float by1 = x_axis + xAxisSpace + graphicHeight;
			[view FillShadedRectangleX0:x1 Y0:by1 X1:x2 Y1:by1 + xAxisSpace WithHighlight:false];
			[view LineRectangleX0:x1 Y0:by1 X1:x2 Y1:by1 + xAxisSpace]; 
			
			by1 = x_axis - graphicHeight;
			[view FillShadedRectangleX0:x1 Y0:by1 X1:x2 Y1:by1 - xAxisSpace WithHighlight:false];
			[view LineRectangleX0:x1 Y0:by1 X1:x2 Y1:by1 - xAxisSpace]; 
			
			if ( s )
			{
				[view SetFGColour:[view white_]];
				NSNumber *t = [NSNumber numberWithInt:s / 60];
				NSString *s = [t stringValue];
				float w, h;
				[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
				[view DrawString:s AtX:x1 - w * 0.5 Y:x_axis + xAxisSpace * 0.5 - h * 0.5];
			}
			
			s = s1;
		}
		
		// Draw the trace
		long count = [kicks[p] count];
		[view SetLineWidth:1.5];
		float lastX, lastY;
		for(int i = 0 ; i < count ; i++)
		{
			BallChunk *chunk = [kicks[p] objectAtIndex:i];
			float v = [chunk position];
			x1 = baseX + [chunk time] * secWidth;
			float x2 = x1 + [chunk position] * secWidth;
			if ( x2 - x1 < 3 )
				x2 = x1 + 3;
			float y1, y2;
			
			if(v > 0)
			{
				if ( v > 50 )
				{
					y1 = x_axis;
					v = (v - 50) / 50;
				}
				else 
				{
					y1 = x_axis + xAxisSpace;
					v = (-50+v) / 50;
				}

				
				[view SetFGColour:[UIColor colorWithRed:0.6 green:0.85 blue:0.92 alpha:0.9]];
			}
			else
			{
				if ( v < -50 )
				{
					y1 = x_axis + xAxisSpace;
					v = (v + 50) / 50;
				}
				else 
				{
					y1 = x_axis;
					v = (50+v) / 50;
				}

				[view SetFGColour:[UIColor colorWithRed:0.9 green:0.47 blue:0.04 alpha:0.9]];
			}

			y2 = y1 - v * graphicHeight;
			
			if ( !chunk.newMove )
				[view LineX0:lastX Y0:lastY X1:x1 Y1:y2];
			lastX = x1;
			lastY = y2;
			
		}
		
		long goal_count = [goals[p] count];
		[view SetLineWidth:2];
		for ( int g = 0; g < goal_count; g++ )
		{
			float v = [[goals[p] objectAtIndex:g] floatValue];
			float g1 = baseX + fabs ( v ) * secWidth;
			float textY;
			[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.9]];
			
			if(v > 0)
			{
				[view LineX0:g1 Y0:x_axis X1:g1 Y1:x_axis - graphicHeight];
				textY = x_axis - graphicHeight - xAxisSpace * 0.5;
				home++;
			}
			else
			{
				[view LineX0:g1 Y0:x_axis + xAxisSpace X1:g1 Y1:x_axis + xAxisSpace + graphicHeight];
				textY = x_axis + xAxisSpace + graphicHeight + xAxisSpace * 0.5;
				away++;
			}
			
			[view SetFGColour:[view black_]];
			NSNumber *n = [NSNumber numberWithInt:home];
			NSString *s = [n stringValue];
			n = [NSNumber numberWithInt:away];
			s = [s stringByAppendingString:@" - "];
			s = [s stringByAppendingString:[n stringValue]];
			float w, h;
			[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
			[view DrawString:s AtX:g1 - w * 0.5 Y:textY - h * 0.5];
		}
			 
		x1 += halfTimeSpace;
	}
			
	[view RestoreFont];	
	[view RestoreGraphicsState];
	
	CGPathRelease(drawingArea);

}

@end
