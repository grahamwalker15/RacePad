//
//  HeadToHead.m
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "Possession.h"
#import "PossessionView.h"
#import "DataStream.h"
#import "MatchPadDataHandler.h"
#import "MatchPadDatabase.h"

@implementation Possession

- (id) init
{
	if(self = [super init])
	{
		data[0]  = [[NSMutableArray alloc] init];
		data[1]  = [[NSMutableArray alloc] init];
		goals[0]  = [[NSMutableArray alloc] init];
		goals[1]  = [[NSMutableArray alloc] init];
	}	
	return self;
}

- (void) dealloc
{
	[self clearData];
	[data[0] release];
	[data[1] release];
	[goals[0] release];
	[goals[1] release];
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////

- (void) clearData
{
	[data[0] removeAllObjects];
	[data[1] removeAllObjects];
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
			float f = [stream PopFloat];
			NSNumber *n = [NSNumber numberWithFloat:f];
			[data[i] addObject:n];
		}
		
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

- (void) drawInView : (PossessionView *)view
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
	float chunkWidth = ([view transformX:1.0 / (float)([data[0] count] + [data[1] count])] - [view transformX:0.0]) * (graphicWidth - halfTimeSpace);
	
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
	
	// Add tick marks every 10%
	
	[view UseMediumBoldFont];
	
	for ( float yval = 0; yval <= 5; yval += 1 )
	{
		double yTop = x_axis - (float)yval / 5 * graphicHeight;
		double yBot = x_axis + xAxisSpace + (float)yval / 5 * graphicHeight;
		
		[view SetLineWidth:0.5];
		[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
		[view LineX0:0 Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
		[view LineX0:0 Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 

		[view SetFGColour:[view white_]];
		[view SetLineWidth:1.5];
		[view LineX0:size.width - yAxisSpace Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
		[view LineX0:size.width - yAxisSpace Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 
		
		NSNumber *n = [NSNumber numberWithInt:50 + yval * 10];
		NSString *s = [n stringValue];
		s = [s stringByAppendingString:@"%"];
		float w, h;
		[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
		[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yTop - h/2];
		[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yBot - h/2];
	}
		
	// Set clipping area for the rest - to exclude y axis
	// Restored with graphic state at the end
	[view SetClippingAreaToPath:drawingArea];
	
	// Draw possession bars
	float x1 = [view transformX:0] * graphicWidth;
	int home = 0;
	int away = 0;
	for ( int p = 0; p < 2; p++ )
	{
		[view SetLineWidth:1];
		float baseX = x1;
		int count = [data[p] count];
		for(int i = 0 ; i < count ; i++)
		{
			NSNumber *num = [data[p] objectAtIndex:i];
			float v = [num floatValue];
			float x2 = x1 + chunkWidth;
			if(fabsf(v) > 0.001)
			{
				float y1, y2;
				
				if(v > 0)
				{
					y1 = x_axis;
					
					[view SetBGColour:[UIColor colorWithRed:0.6 green:0.85 blue:0.92 alpha:0.7]];
				}
				else
				{
					y1 = x_axis + xAxisSpace;
					[view SetBGColour:[UIColor colorWithRed:0.9 green:0.47 blue:0.04 alpha:0.7]];
				}

				y2 = y1 - v * graphicHeight;
				
				[view SetFGColour:[view white_]];
				[view FillShadedRectangleX0:x1 Y0:y1 X1:x2 Y1:y2 WithHighlight:false];
				[view LineRectangleX0:x1 Y0:y1 X1:x2 Y1:y2];
			}
			
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

			if ( (i % 10) == 5 )
			{
				[view SetFGColour:[view white_]];
				NSNumber *t = [NSNumber numberWithInt:i * 1];
				NSString *s = [t stringValue];
				float w, h;
				[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
				[view DrawString:s AtX:x1 - w * 0.5 Y:x_axis + xAxisSpace * 0.5 - h * 0.5];
			}
			
			x1 += chunkWidth;
		}
		
		int goal_count = [goals[p] count];
		[view SetLineWidth:2];
		for ( int g = 0; g < goal_count; g++ )
		{
			float v = [[goals[p] objectAtIndex:g] floatValue];
			float g1 = baseX + fabs ( v ) * chunkWidth;
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
			
			[view SetFGColour:[view white_]];
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
