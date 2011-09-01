//
//  HeadToHead.m
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHead.h"
#import "HeadToHeadView.h"
#import "DataStream.h"

@implementation HeadToHeadLap

@synthesize gap;
@synthesize pos0;
@synthesize pos1;
@synthesize pit0;
@synthesize pit1;

- (HeadToHeadLap *) initWithStream: (DataStream *) stream
{
	if ( [super init] == self )
	{
		pos0 = [stream PopInt];
		pit0 = [stream PopBool];
		pos1 = [stream PopInt];
		pit1 = [stream PopBool];
		gap = [stream PopFloat];
	}
	
	return self;
}

@end


@implementation HeadToHead

@synthesize driver0;
@synthesize driver1;
@synthesize abbr0;
@synthesize firstName0;
@synthesize surname0;
@synthesize teamName0;
@synthesize abbr1;
@synthesize firstName1;
@synthesize surname1;
@synthesize teamName1;
@synthesize completedLapCount;
@synthesize laps;

- (id) init
{
	if(self = [super init])
	{
		driver0 =nil;
		driver1 =nil;
		
		abbr0 = nil;
		firstName0 = nil;
		surname0 = nil;
		teamName0 = nil;
		abbr1 = nil;
		firstName1 = nil;
		surname1 = nil;
		teamName1 = nil;
		
		laps = [[NSMutableArray alloc] init];
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
	[driver0 release];
	[driver1 release];
	
	[abbr0 release];	
	[firstName0 release];
	[surname0 release];
	[teamName0 release];
	[abbr1 release];	
	[firstName1 release];
	[surname1 release];
	[teamName1 release];
	
	driver0 = nil;
	driver1 = nil;
	
	abbr0 = nil;
	firstName0 = nil;
	surname0 = nil;
	teamName0 = nil;
	abbr1 = nil;
	firstName1 = nil;
	surname1 = nil;
	teamName1 = nil;
	
	[laps release];
	laps = nil;
}

- (void) loadData : (DataStream *) stream
{
	[abbr0 release];	
	[firstName0 release];
	[surname0 release];
	[teamName0 release];
	[abbr1 release];	
	[firstName1 release];
	[surname1 release];
	[teamName1 release];
	[laps release];
	
	abbr0 = [[stream PopString] retain];
	firstName0 = [[stream PopString] retain];
	surname0 = [[stream PopString] retain];
	teamName0 = [[stream PopString] retain];
	abbr1 = [[stream PopString] retain];
	firstName1 = [[stream PopString] retain];
	surname1 = [[stream PopString] retain];
	teamName1 = [[stream PopString] retain];
	
	completedLapCount = [stream PopInt];
	totalLapCount = [stream PopInt];
	laps = [[NSMutableArray alloc] initWithCapacity:totalLapCount + 1];
	for ( int i = 0; i <= totalLapCount; i++ )
	{
		HeadToHeadLap *lap = [[HeadToHeadLap alloc] initWithStream: stream];
		[laps addObject:lap];
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
// Drawing

- (void) drawInView : (HeadToHeadView *)view
{
	/*
	if ( kerbImage == nil )
	{
		grassImage = [[UIImage imageNamed:@"Grass.png"] retain];
		kerbImage = [[UIImage imageNamed:@"Kerbs.png"] retain];
		trackImage = [[UIImage imageNamed:@"Metal.png"] retain];
	}
	 */
	
	// Find maximum gap
	float maxGap = 0.0;
	
	if(totalLapCount > 0)
	{
		for(int i = 0 ; i < totalLapCount ; i++)
		{
			HeadToHeadLap * lap = [laps objectAtIndex:i];
			if(lap)
			{
				float gap = fabs([lap gap]);
				
				if(gap > maxGap)
					maxGap = gap;
			}
		}
	}
	
	// Make it a minimum of 10s and round up to nearest 5
	if(maxGap < 10.0)
	{
		maxGap = 10.0;
	}
	else
	{
		maxGap = ceilf(maxGap / 5.0) * 5.0;
	}
	
	// Cap at 2 mins
	if(maxGap > 120.0)
		maxGap = 120.0;

	// Now start drawing
	
	CGSize size = [view InqSize];
	
	float xAxisSpace = 25;
	float yAxisSpace = 50;
	float graphicWidth = size.width - yAxisSpace;
	float graphicHeight = (size.height - xAxisSpace * 3) * 0.5;
	int x_axis = size.height * 0.5 - xAxisSpace * 0.5;
		
	CGMutablePathRef drawingArea = [DrawingView CreateRectPathX0:0 Y0:0 X1:graphicWidth Y1:size.height];
	
	[view SaveGraphicsState];
	
	// Draw Y Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	[view FillRectangleX0:size.width - yAxisSpace Y0:0 X1:size.width - yAxisSpace + 2 Y1:size.height];
	
	// Add tick marks every second with labels every 5-20 secs depending on max
	
	[view SaveFont];
	[view UseRegularFont];
	
	int tickSpacing = maxGap < 60 ? 5 : maxGap < 120 ? 10 : maxGap < 180 ? 15 : 20;
	
	for ( int yval = 1; yval < maxGap; yval += 1 )
	{
		double yTop = x_axis - (float)yval / maxGap * graphicHeight;
		double yBot = x_axis + xAxisSpace + (float)yval / maxGap * graphicHeight;
		
		if ((yval % tickSpacing) == 0 )
		{
			[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
			[view LineRectangleX0:0 Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
			[view LineRectangleX0:0 Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 

			[view SetFGColour:[view white_]];
			[view LineRectangleX0:size.width - yAxisSpace Y0:yTop X1:size.width - yAxisSpace + 5 Y1:yTop]; 
			[view LineRectangleX0:size.width - yAxisSpace Y0:yBot X1:size.width - yAxisSpace + 5 Y1:yBot]; 
			
			NSNumber *n = [NSNumber numberWithInt:yval];
			NSString *s = [n stringValue];
			s = [s stringByAppendingString:@"s"];
			float w, h;
			[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
			[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yTop - h/2];
			[view DrawString:s AtX:size.width - yAxisSpace + 8 Y:yBot - h/2];
		}
		else
		{
			[view SetFGColour:[view white_]];
			[view LineRectangleX0:size.width - yAxisSpace Y0:yTop X1:size.width - yAxisSpace + 3 Y1:yTop]; 
			[view LineRectangleX0:size.width - yAxisSpace Y0:yBot X1:size.width - yAxisSpace + 3 Y1:yBot]; 
		}
	}
	
	[view RestoreFont];	
	
	// Set clipping area for the rest - to exclude y axis
	// Restored with graphic state at the end
	[view SetClippingAreaToPath:drawingArea];
	
	// Draw safety car laps
	[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.2]];
	[view SetBGColour:[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.2]];
	if(totalLapCount > 0)
	{
		for(int i = 1 ; i < totalLapCount ; i++)
		{
			HeadToHeadLap * lap = [laps objectAtIndex:i];
			if(lap)
			{
				if(i > 10 && i <= 15 || i > 40 && i <= 45)
				{
					float x1 = [view transformX:((float)i - 1.0) / (float)totalLapCount] * graphicWidth;
					float x2 = [view transformX:((float)i ) / (float)totalLapCount] * graphicWidth;
		
					[view FillShadedRectangleX0:x1 Y0:0 X1:x2 Y1:size.height WithHighlight:false];
					[view LineRectangleX0:x1 Y0:0 X1:x2 Y1:size.height];
				}
			}
		}
	}
	
	// Draw X axis background and driver strap backgrounds
	[view SetFGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
	[view SetBGColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2]];
	for ( int lap = 1; lap <= totalLapCount; lap++ )
	{			
		float x1 = [view transformX:((float)lap - 1.0) / (float)totalLapCount] * graphicWidth;
		float x2 = [view transformX:((float)lap ) / (float)totalLapCount] * graphicWidth;
		
		[view FillShadedRectangleX0:x1 Y0:x_axis X1:x2 Y1:x_axis + xAxisSpace WithHighlight:false];
		[view LineRectangleX0:x1 Y0:x_axis X1:x2 Y1:x_axis + xAxisSpace]; 
		
		[view FillShadedRectangleX0:x1 Y0:size.height X1:x2 Y1:size.height - xAxisSpace WithHighlight:false];
		[view LineRectangleX0:x1 Y0:size.height X1:x2 Y1:size.height - xAxisSpace]; 

		[view FillShadedRectangleX0:x1 Y0:0 X1:x2 Y1:xAxisSpace WithHighlight:false];
		[view LineRectangleX0:x1 Y0:0 X1:x2 Y1:xAxisSpace]; 
	}

	// Draw X Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	
	// Draw centre line
	[view LineRectangleX0:0 Y0:x_axis X1:graphicWidth Y1:x_axis + xAxisSpace];
	
	// X Axis
	[view FillRectangleX0:0 Y0:x_axis X1:graphicWidth Y1:x_axis+2];
	
	// Add tick marks every lap with labels every 5
		
	[view SaveFont];
	[view UseMediumBoldFont];
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];


	for ( int lap = 1; lap <= totalLapCount; lap++ )
	{			
		float xval = [view transformX:(float)lap / (float)totalLapCount] * graphicWidth;
		
		if ((lap % 5) == 0 )
		{
			[view LineRectangleX0:xval Y0:x_axis X1:xval Y1:x_axis + 5]; 
				
			NSNumber *n = [NSNumber numberWithInt:lap];
			NSString *s = [NSString stringWithString:@"L"];
			s = [s stringByAppendingString:[n stringValue]];
			float w, h;
			[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
			[view DrawString:s AtX:xval - w / 2 Y:x_axis + 4];
		}
		else
		{
			[view LineRectangleX0:xval Y0:x_axis X1:xval Y1:x_axis + 3]; 
		}
	}
	
	
	// Draw gaps
	if(totalLapCount > 0)
	{
		for(int i = 1 ; i < totalLapCount ; i++)
		{
			HeadToHeadLap * lap = [laps objectAtIndex:i];
			if(lap)
			{
				float gap = [lap gap];
				bool pit0 = [lap pit0];
				bool pit1 = [lap pit1];
					
				if(fabsf(gap) > 0.001)
				{
					float y1, y2;
					
					if(gap > 0)
					{
						y1 = x_axis;
						[view SetBGColour:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:0.7]];
					}
					else
					{
						y1 = x_axis + xAxisSpace;
						[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.7]];
					}

					y2 = y1 - (float)gap / maxGap * graphicHeight;

					float x1 = [view transformX:((float)i - 1.0) / (float)totalLapCount] * graphicWidth;
					float x2 = [view transformX:((float)i) / (float)totalLapCount] * graphicWidth;
					
					[view SetFGColour:[view white_]];
					[view FillShadedRectangleX0:x1 Y0:y1 X1:x2 Y1:y2 WithHighlight:false];
					[view LineRectangleX0:x1 Y0:y1 X1:x2 Y1:y2];
					
					if(pit0)
					{
						[view SetFGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.2]];
						[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.2]];
						[view FillShadedRectangleX0:x1 Y0:x_axis X1:x2 Y1:xAxisSpace WithHighlight:false];
						[view LineRectangleX0:x1 Y0:x_axis X1:x2 Y1:xAxisSpace];
						
						[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.7]];
						[view SetFGColour:[view white_]];
						[view FillShadedRectangleX0:x1 Y0:0 X1:x2 Y1:xAxisSpace WithHighlight:false];
						[view LineRectangleX0:x1 Y0:0 X1:x2 Y1:xAxisSpace];
					}
					
					if(pit1)
					{
						[view SetFGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.2]];
						[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.2]];
						[view FillShadedRectangleX0:x1 Y0:x_axis + xAxisSpace X1:x2 Y1:size.height - xAxisSpace WithHighlight:false];
						[view LineRectangleX0:x1 Y0:x_axis + xAxisSpace X1:x2 Y1:size.height - xAxisSpace];
						
						[view SetBGColour:[UIColor colorWithRed:0.8 green:0.0 blue:0.9 alpha:0.7]];
						[view SetFGColour:[view white_]];
						[view FillShadedRectangleX0:x1 Y0:size.height X1:x2 Y1:size.height - xAxisSpace WithHighlight:false];
						[view LineRectangleX0:x1 Y0:size.height X1:x2 Y1:size.height - xAxisSpace];
					}
				}
			}
		}		
	}
	
	
	[view RestoreGraphicsState];
	
	CGPathRelease(drawingArea);

}


@end
