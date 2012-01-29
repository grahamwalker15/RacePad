//
//  CommentaryView.m
//  RacePad
//
//  Created by Gareth Griffith on 1/18/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//


#import "CommentaryView.h"

#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TableData.h"
#import "CommentaryData.h"
#import "ElapsedTime.h"
#import "CommentaryBubbleViewController.h"

@implementation CommentaryView

@synthesize timeWindow;
@synthesize smallFont;
@synthesize midasStyle;
@synthesize minPriority;
@synthesize lastUpdateTime;
@synthesize latestMessageTime;
@synthesize firstMessageTime;
@synthesize firstDisplayedTime;
@synthesize lastDisplayedTime;
@synthesize lastRowCount;
@synthesize updating;
@synthesize bubbleController;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		midasStyle = false;
		
		lastRowCount = 0;
		lastHeight = 0;
		latestMessageTime = 0.0;
		firstRow = 0;
		timeWindow = 0;
		smallFont = false;
		minPriority = 0;
		lastUpdateTime = 0;
		updating = true;
		[self SetBaseColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	}
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		midasStyle = false;
		
		lastRowCount = 0;
		lastHeight = 0;
		latestMessageTime = 0.0;
		firstRow = 0;
		timeWindow = 0;
		smallFont = false;
		minPriority = 0;
		lastUpdateTime = 0;
		updating = true;
		[self SetBaseColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
   }
    return self;
}

- (void)dealloc
{
	[bubbleController release];
    [super dealloc];
}

- (void) redrawAtEnd
{
	[self RequestScrollToEnd];
	
	lastUpdateTime = [ElapsedTime TimeOfDay] - ([[RacePadCoordinator Instance] playTime] - latestMessageTime);
}

- (void) RequestRedrawForUpdate
{
	int rowCount, fRow;
	[self countRows: &rowCount FirstRow: &fRow];
	
	CGRect bounds = [self bounds];
	
	int height = bounds.size.height;
	if ( bubbleController )
		[bubbleController sizeCommentary: rowCount FromHeight:height];
	[self redrawAtEnd];
	// [super RequestRedrawForUpdate];
}

- (void) drawIfChanged
{
	if ( updating )
	{
		int rowCount, fRow;
		[self countRows: &rowCount FirstRow: &fRow];
		
		CGRect bounds = [self bounds];
		
		int height = bounds.size.height;
		if ( ( rowCount != lastRowCount
			  || height != lastHeight
			  || fRow != firstRow )
			&& rowCount > 0 )
		{
			if ( bubbleController )
				[bubbleController sizeCommentary: rowCount FromHeight:height];
			[self redrawAtEnd];
		}
	}
}

- (void) initialDraw
{
	if ( updating )
	{
		int rowCount, fRow;
		[self countRows: &rowCount FirstRow: &fRow];
		
		if ( bubbleController )
			[bubbleController sizeCommentary: rowCount FromHeight:0];
		[self redrawAtEnd];
	}
}

- (void) Draw:(CGRect)region
{
	if ( updating )
	{
		int rowCount, fRow;
		[self countRows: &rowCount FirstRow: &fRow];
		
		CGRect bounds = [self bounds];
		
		lastRowCount = rowCount;
		lastHeight = bounds.size.height;
		firstRow = fRow;
		
		firstDisplayedTime = firstMessageTime;
		lastDisplayedTime = latestMessageTime;

		[super Draw:region];
	}
}

- (void) resetTimings
{
	firstDisplayedTime = 0;
	lastDisplayedTime = 0;
}

- (int) RowCount
{
	int count, fRow;
	[self countRows:&count FirstRow:&fRow];
	return count;
}

- (void) countRows: (int*) count FirstRow: (int *) fRow
{
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	float timeNow = [[RacePadCoordinator Instance] playTime];
	
	*count = 0;
	*fRow = 0;
	bool first = true;
	latestMessageTime = 0.0;
	firstMessageTime = 0.0;
	
	for (int i = 0 ; i < [data itemCount] ; i++)
	{
		AlertDataItem *item = [data itemAtIndex:i];
		float itemTime = [item timeStamp];
		
		if ( itemTime >= timeWindow )
		{
			if ( itemTime <= timeNow + 0.5
			  && item.confidence >= minPriority )
			{
				if ( first )
				{
					firstMessageTime = itemTime;
					*fRow = i;
				}
				else
					if ( itemTime < firstMessageTime )
						firstMessageTime = itemTime;
				
				first = false;
				*count = *count + 1;
				if ( itemTime > latestMessageTime )
					latestMessageTime = itemTime;
			}
		}
	}
}

- (int) ColumnCount
{
	return 3;
}

- (int) ContentRowHeight:(int)row
{
	if ( smallFont )
		return 18;
	
	return 28;
}

- (int) ColumnWidth:(int)col;
{
	CGRect bounds = [self bounds];
	
	if ( smallFont )
		switch (col)
		{
			case 0:
				return 20;
			case 1:
				return 38;
			case 2:
				return (bounds.size.width - 58);
			default:
				return 0;
		}
	else
		switch (col)
		{
			case 0:
				return 30;
			case 1:
				return 60;
			case 2:
				return (bounds.size.width - 90);
			default:
				return 0;
		}
}

- (int) ColumnType:(int)col;
{	
	// Reach here if data could not be found in table
	return SLV_COL_STANDALONE_;
}

- (int) ColumnUse:(int)col;
{
	return TD_USE_FOR_BOTH;
}

- (void) SetDefaultFormatting:(bool)if_heading
{
	[super SetDefaultFormatting:if_heading];
	if ( smallFont )
	{
		[self UseLargerControlFont];
	}
}

- (int) InqCellTypeAtRow:(int)row Col:(int)col
{
	switch (col)
	{
		case 0:
			return SLV_IMAGE_CELL_;
		case 1:
			return SLV_TEXT_CELL_;
		case 2:
			return SLV_TEXT_CELL_;
		default:
			return SLV_TEXT_CELL_;
	}
}

- (void) PrepareRow:(int)row
{
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	float timeNow = [[RacePadCoordinator Instance] playTime];
	
	int count = 0;
	
	for (int i = 0 ; i < [data itemCount] ; i++)
	{
		AlertDataItem *item = [data itemAtIndex:i];
		float itemTime = [item timeStamp];
		
		if ( itemTime >= timeWindow )
		{
			if ( itemTime <= timeNow + 0.5
			  && item.confidence >= minPriority )
			{
				if ( row == count )
				{
					currentRow = i;
					return;
				}
				count++;
			}
		}
	}
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	float messageTime = [[data itemAtIndex:currentRow] timeStamp];
	int type = [[data itemAtIndex:currentRow] type];
	
	// Colours depend on style
	if(midasStyle)
	{
		if(type == ALERT_PIT_INSIGHT_)
			[self SetTextColour:very_light_blue_];
		else if(latestMessageTime - messageTime < 10.0)
			[self SetTextColour:white_];
		else
			[self SetTextColour:very_light_grey_];
		
		[self SetBackgroundColour:black_];
	}
	else
	{
		if(type == ALERT_PIT_INSIGHT_)
			[self SetTextColour:dark_red_];
		else if(latestMessageTime - messageTime < 10.0)
			[self SetTextColour:black_];
		else
			[self SetTextColour:very_dark_grey_];
		
		[self SetBackgroundColour:white_];
	}

	
	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
		{
			int lap = [[data itemAtIndex:currentRow] lap];
			float timeStamp = [[data itemAtIndex:currentRow] timeStamp];
			
			if(lap > 0)
			{
				return [NSString stringWithFormat:@"L%d", lap];
			}
			else
			{
				int h = (int)(timeStamp / 3600.0); timeStamp -= h * 3600;
				int m = (int)(timeStamp / 60.0);
				return [NSString stringWithFormat:@"%d:%02d", h, m];
			}
		}
		case 2:
		{
			return [[data itemAtIndex:currentRow] description];
		}
		default:
		{
			return @"";
		}
	}
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	if(midasStyle)
		[self SetBackgroundColour:black_];
	else
		[self SetBackgroundColour:white_];
	
	if(col != 0)
		return nil;
	
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	int type = [[data itemAtIndex:currentRow] type];
	
	switch (type)
	{
		case ALERT_RACE_EVENT_:
		case ALERT_USER_EVENT_:
			return [UIImage imageNamed:@"AlertPin.png"];
		case ALERT_INCIDENT_:
		case ALERT_CAR_STOPPED_:
		case ALERT_OFF_TRACK_:
			return [UIImage imageNamed:@"AlertWarning.png"];
		case ALERT_OVERTAKE_:
			return [UIImage imageNamed:@"AlertOvertake.png"];
		case ALERT_SAFETY_CAR_:
		case ALERT_OVERTAKE_SC_:
		case ALERT_SC_SPEEDING_:
		case ALERT_SC_VIOLATION_:
			return [UIImage imageNamed:@"AlertSafetyCar.png"];
		case ALERT_GREEN_FLAG_:
		case ALERT_CAR_CONTINUED_:
			return [UIImage imageNamed:@"AlertGreenFlag.png"];
		case ALERT_RED_FLAG_:
			return [UIImage imageNamed:@"AlertRedFlag.png"];
		case ALERT_PIT_STOP_:
			return [UIImage imageNamed:@"AlertPitstop.png"];
		case ALERT_YELLOW_FLAG_:
		case ALERT_YELLOW_SPEEDING_:
		case ALERT_YELLOW_VIOLATION_:
			return [UIImage imageNamed:@"AlertYellowFlag.png"];
		case ALERT_CHEQUERED_FLAG_:
			return [UIImage imageNamed:@"AlertChequeredFlag.png"];
		case ALERT_PIT_INSIGHT_:
			return [UIImage imageNamed:@"AlertInsight.png"];
		case ALERT_LAP_COMPLETE_:
			return [UIImage imageNamed:@"AlertLC.png"];
		case ALERT_INFO_:
			return [UIImage imageNamed:@"AlertInfo.png"];
		case ALERT_PERFORMANCE_GREEN_:
			return [UIImage imageNamed:@"AlertGreenInfo.png"];
		case ALERT_PERFORMANCE_PURPLE_:
			return [UIImage imageNamed:@"AlertPurpleInfo.png"];
		default:
			return [UIImage imageNamed:@"AlertPin.png"];
	}			
}

- (UIImage *) GetCellClientImageAtRow:(int)row Col:(int)col
{
	return nil;
}

- (NSString *) GetHeadingAtCol:(int)col
{
	return nil;	
}

@end

