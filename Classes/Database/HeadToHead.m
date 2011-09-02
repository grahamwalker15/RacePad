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

static UIImage *greenPosArrowImage = nil;
static UIImage *redPosArrowImage = nil;

@implementation HeadToHeadLap

@synthesize gap;
@synthesize pos0;
@synthesize pos1;
@synthesize flags0;
@synthesize flags1;

- (HeadToHeadLap *) initWithStream: (DataStream *) stream
{
	if ( [super init] == self )
	{
		pos0 = [stream PopInt];
		flags0 = [stream PopInt];
		pos1 = [stream PopInt];
		flags1 = [stream PopInt];
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
	if ( greenPosArrowImage == nil )
	{
		greenPosArrowImage = [[UIImage imageNamed:@"ArrowUpGreen.png"] retain];
		redPosArrowImage = [[UIImage imageNamed:@"ArrowDownRed.png"] retain];
	}
	
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
	
	// Work out width of a lap column, and thereby what content we can draw
	float lapWidth = ([view transformX:1.0 / (float)totalLapCount] - [view transformX:0.0]) * graphicWidth;
	
	bool drawArrows = lapWidth >= 10;
	bool drawPosText = lapWidth >= 15;
	bool drawPitTextMini = lapWidth >= 15;
	bool drawPitText = lapWidth >= 30;

	// And start drawing...
	
	[view SaveGraphicsState];
	[view SaveFont];
	
	// Draw Y Axis
	[view SetFGColour:[view white_]];
	[view SetBGColour:[view white_]];
	[view FillRectangleX0:size.width - yAxisSpace Y0:0 X1:size.width - yAxisSpace + 2 Y1:size.height];
	
	// Add tick marks every second with labels every 5-20 secs depending on max
	
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
				float x1 = [view transformX:((float)i - 1.0) / (float)totalLapCount] * graphicWidth;
				float x2 = [view transformX:((float)i ) / (float)totalLapCount] * graphicWidth;
		
				bool sc0 = (lap.flags0 & H2H_SC_) > 0;
				bool sc1 = (lap.flags1 & H2H_SC_) > 0;
				
				if(sc0)
				{
					[view FillShadedRectangleX0:x1 Y0:x_axis X1:x2 Y1:0 WithHighlight:false];
					[view LineRectangleX0:x1 Y0:x_axis X1:x2 Y1:0];
				}
				
				if(sc1)
				{
					[view FillShadedRectangleX0:x1 Y0:x_axis + xAxisSpace X1:x2 Y1:size.height WithHighlight:false];
					[view LineRectangleX0:x1 Y0:x_axis + xAxisSpace X1:x2 Y1:size.height];
				}
			}
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
		
	// Draw text overlays
	if(totalLapCount > 0)
	{
		HeadToHeadLap * lap0 = [laps objectAtIndex:0];
		int prevPos0 = lap0 ? [lap0 pos0] : -1;
		int prevPos1 = lap0 ? [lap0 pos1] : -1;

		for(int i = 1 ; i < totalLapCount ; i++)
		{
			HeadToHeadLap * lap = [laps objectAtIndex:i];
			if(lap)
			{
				float x1 = [view transformX:((float)i - 1.0) / (float)totalLapCount] * graphicWidth;
				float x2 = [view transformX:((float)i ) / (float)totalLapCount] * graphicWidth;
				float xCentre = (x1 + x2) * 0.5;

				int pos0 = [lap pos0];
				int pos1 = [lap pos1];
				bool pit0 = (lap.flags0 & H2H_PIT_) > 0;
				bool pit1 = (lap.flags1 & H2H_PIT_) > 0;
					
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
					
					if(drawPitText || drawPitTextMini)
					{
						if(drawPitText)
							[view UseRegularFont];
						else
							[view UseControlFont];
						
						NSString *s = [NSString stringWithString:@"IN"];
						float w, h;
						[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
						[view DrawString:s AtX:xCentre - w / 2 Y:(xAxisSpace - h) * 0.5];
					}
				}
				else
				{
					if(i == 1 || pos0 != prevPos0)
					{
						if(drawArrows)
						{
							if(pos0 > prevPos0)
								[view DrawImage:redPosArrowImage AtX:xCentre - 5  Y:xAxisSpace - 11];
							else if(pos0 < prevPos0)
								[view DrawImage:greenPosArrowImage AtX:xCentre - 5  Y:xAxisSpace - 11];
						}

						if(drawPosText)
						{
							[view UseControlFont];
							
							NSNumber *n = [NSNumber numberWithInt:pos0];
							NSString *s = [NSString stringWithString:[n stringValue]];
							float w, h;
							[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
							[view DrawString:s AtX:xCentre - w / 2 Y:0];
						}
						
						prevPos0 = pos0;
					}
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
					if(drawPitText || drawPitTextMini)
					{
						if(drawPitText)
							[view UseRegularFont];
						else
							[view UseControlFont];
						
						NSString *s = [NSString stringWithString:@"IN"];
						float w, h;
						[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
						[view DrawString:s AtX:xCentre - w / 2 Y:size.height - xAxisSpace + (xAxisSpace - h) * 0.5];
					}
				}
				else
				{
					if(i == 1 || pos1 != prevPos1)
					{
						if(drawArrows)
						{
							if(pos1 > prevPos1)
								[view DrawImage:redPosArrowImage AtX:xCentre - 5  Y:size.height - xAxisSpace + 1];
							else if(pos1 < prevPos1)
								[view DrawImage:greenPosArrowImage AtX:xCentre - 5  Y:size.height - xAxisSpace + 1];
						}
						
						if(drawPosText)
						{
							[view UseControlFont];
							
							NSNumber *n = [NSNumber numberWithInt:pos1];
							NSString *s = [NSString stringWithString:[n stringValue]];
							float w, h;
							[view GetStringBox:s WidthReturn:&w HeightReturn:&h];
							[view DrawString:s AtX:xCentre - w / 2 Y:size.height - h];
						}
						
						prevPos1 = pos1;
					 }
				}
			}
		}		
	}
	
	[view RestoreFont];	
	[view RestoreGraphicsState];
	
	CGPathRelease(drawingArea);

}

@end
