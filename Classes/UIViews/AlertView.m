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
	//[table_data_ release];
	
    [super dealloc];
}

- (int) RowCount
{
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	return [alertData itemCount];
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
			return 320;
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
	[self SetTextColour:black_];
	[self SetBackgroundColour:white_];
	
	AlertData * alertData = [[RacePadDatabase Instance] alertData];

	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
		{
			return [NSString stringWithFormat:@"L%d", [[alertData itemAtIndex:row] lap]];
		}
		case 2:
		{
			return [[alertData itemAtIndex:row] description];
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
	int type = [[alertData itemAtIndex:row] type];

	switch (type)
	{
		case ALERT_RACE_EVENT_:
			return [UIImage imageNamed:@"AlertPin.png"];
		case ALERT_INCIDENT_:
			return [UIImage imageNamed:@"AlertWarning.png"];
		case ALERT_OVERTAKE_:
			return [UIImage imageNamed:@"AlertOvertake.png"];
		case ALERT_SAFETY_CAR_:
			return [UIImage imageNamed:@"AlertSafetyCar.png"];
		case ALERT_GREEN_FLAG_:
			return [UIImage imageNamed:@"AlertGreenFlag.png"];
		case ALERT_RED_FLAG_:
			return [UIImage imageNamed:@"AlertRedFlag.png"];
		case ALERT_PIT_STOP_:
			return [UIImage imageNamed:@"AlertPitstop.png"];
		case ALERT_YELLOW_VIOLATION_:
			return [UIImage imageNamed:@"AlertYellowFlag.png"];
		case ALERT_CHEQUERED_FLAG_:
			return [UIImage imageNamed:@"AlertChequeredFlag.png"];
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

