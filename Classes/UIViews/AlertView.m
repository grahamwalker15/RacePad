//
//  AlertView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertView.h"

#import "RacePadDatabase.h"
#import "TableData.h"
#import "AlertData.h"

@implementation AlertView


- (void)dealloc
{
    [super dealloc];
}

-(void) setFilter:(int) type
{
	filter = type;
}

- (void)PrepareData
{
	[super PrepareData];
	[self SetBaseColour:white_];
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
	switch (col)
	{
		case 0:
			return 30;
		case 1:
			return 50;
		case 2:
			return 420;
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

- (bool) includeRow:(int) row
{
	if ( filter == AV_ALL_ )
		return true;
	
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	int type = [[alertData itemAtIndex:row] type];
	
	switch (type)
	{
		case ALERT_OVERTAKE_:
			return filter == AV_OVERTAKE_;
		case ALERT_PIT_STOP_:
			return filter == AV_PIT_;
		case ALERT_RACE_EVENT_:
		case ALERT_USER_EVENT_:
		case ALERT_GREEN_FLAG_:
		case ALERT_RED_FLAG_:
		case ALERT_SAFETY_CAR_:
		case ALERT_CHEQUERED_FLAG_:
			return filter == AV_EVENT_;
		default:
			return filter == AV_OTHER_;
	}				
}

- (int) RowCount
{
	int count = 0;
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	if ( filter == AV_ALL_ )
		return [alertData itemCount];
	
	for (int i = 0 ; i < [alertData itemCount] ; i++)
		if ( [self includeRow:i] )
			count++;
	
	return count;
}

- (int) filteredRowToDataRow:(int) row
{
	if ( filter == AV_ALL_ )
		return row;
	
	int filteredRow = 0;
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	for (int i = 0 ; i < [alertData itemCount] ; i++)
		if ( [self includeRow:i] )
		{
			if ( filteredRow == row )
				return i;
			filteredRow++;
		}
	
	return 0;
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	[self SetTextColour:black_];
	[self SetBackgroundColour:white_];
	
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	int dataRow = [self filteredRowToDataRow:row];

	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
		{
			return [NSString stringWithFormat:@"L%d", [[alertData itemAtIndex:dataRow] lap]];
		}
		case 2:
		{
			return [[alertData itemAtIndex:dataRow] description];
		}
		default:
		{
			return @"";
		}
	}
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	[self SetBackgroundColour:white_];
	
	if(col != 0)
		return nil;
	
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	int dataRow = [self filteredRowToDataRow:row];
	int type = [[alertData itemAtIndex:dataRow] type];

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

