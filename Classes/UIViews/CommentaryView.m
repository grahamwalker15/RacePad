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

@implementation CommentaryView

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		lastRowCount = 0;
		lastHeight = 0;
		latestMessageTime = 0.0;
		[self SetBaseColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	}
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		lastRowCount = 0;
		lastHeight = 0;
		latestMessageTime = 0.0;
		[self SetBaseColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void) drawIfChanged
{
	int rowCount = [self RowCount];
	
	CGRect bounds = [self bounds];
	
	int height = bounds.size.height;
	if ( ( rowCount != lastRowCount
		  || height != lastHeight )
		&& rowCount > 0 )
		[self RequestRedraw];
}

- (void) Draw:(CGRect)region
{
	int rowCount = [self RowCount];
	
	CGRect bounds = [self bounds];
	
	int height = bounds.size.height;
	if ( ( rowCount != lastRowCount
		|| height != lastHeight )
	  && rowCount > 0 )
		[self RequestScrollToEnd];
	
	lastRowCount = rowCount;
	lastHeight = height;

	[super Draw:region];	
}

- (int) RowCount
{
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	float timeNow = [[RacePadCoordinator Instance] playTime];
	
	int count = 0;
	latestMessageTime = 0.0;
	
	for (int i = 0 ; i < [data itemCount] ; i++)
	{
		float itemTime = [[data itemAtIndex:i] timeStamp];

		if(itemTime <= timeNow)
		{
			count++;
			latestMessageTime = [[data itemAtIndex:i] timeStamp];
		}
	}
	return count;
}

- (int) ColumnCount
{
	return 3;
}

- (int) RowHeight
{
	return 28;
}

- (int) ColumnWidth:(int)col;
{
	CGRect bounds = [self bounds];
	
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

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	float messageTime = [[data itemAtIndex:row] timeStamp];
	int type = [[data itemAtIndex:row] type];
	
	if(type == ALERT_PIT_INSIGHT_)
		[self SetTextColour:dark_red_];
	else if(latestMessageTime - messageTime < 10.0)
		[self SetTextColour:black_];
	else
		[self SetTextColour:very_dark_grey_];
	
	[self SetBackgroundColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	
	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
		{
			int lap = [[data itemAtIndex:row] lap];
			float timeStamp = [[data itemAtIndex:row] timeStamp];
			
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
			return [[data itemAtIndex:row] description];
		}
		default:
		{
			return @"";
		}
	}
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	[self SetBackgroundColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]];
	
	if(col != 0)
		return nil;
	
	CommentaryData * data;
	data = [[RacePadDatabase Instance] commentary];
	
	int type = [[data itemAtIndex:row] type];
	
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

