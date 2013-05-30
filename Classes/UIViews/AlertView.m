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

@synthesize defaultBackgroundColour;
@synthesize defaultTextColour;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self setDefaultTextColour:black_];
		[self setDefaultBackgroundColour:white_];
		[self setStandardRowHeight:28];
	}
	
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self setDefaultTextColour:black_];
		[self setDefaultBackgroundColour:white_];
    }
    return self;
}

- (void)dealloc
{
	[defaultTextColour release];
	[defaultBackgroundColour release];
    [super dealloc];
}

-(void) setFilter:(int) type Driver:(NSString *)inDriver
{
	filter = type;
	driver = inDriver;
}

- (void)PrepareData
{
	[super PrepareData];
	[self SetBaseColour:defaultBackgroundColour];
}

- (int) ColumnCount
{
	return 5;
}

- (int) ColumnWidth:(int)col;
{
	switch (col)
	{
		case 0:
			return 30;
		case 1:
			return 60;
		case 2:
			return 610;
		case 3:
			return 0;
		case 4:
			return 0;
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
	if ( col == 3 || col == 4 )
		return TD_USE_FOR_NONE;
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
		case 3:
			return SLV_TEXT_CELL_;
		case 4:
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
	
	if ( filter == AV_DRIVER_ )
	{
		if ( driver == nil )
			return true;
		
		AlertDataItem *data = [alertData itemAtIndex:row];
		if ( data
			&& ( [[data focus] isEqualToString:driver]  || [[data focus2] isEqualToString:driver] ) )
			return true;
		
		return false;
	}
	
	switch (type)
	{
		case ALERT_OVERTAKE_:
			return filter == AV_OVERTAKE_;
		case ALERT_PIT_STOP_:
			return filter == AV_PIT_;
		case ALERT_INCIDENT_:
		case ALERT_OFF_TRACK_:
		case ALERT_CAR_STOPPED_:
		case ALERT_CAR_CONTINUED_:
			return filter == AV_INCIDENT_;
		case ALERT_RACE_EVENT_:
		case ALERT_USER_EVENT_:
		case ALERT_GREEN_FLAG_:
		case ALERT_RED_FLAG_:
		case ALERT_SAFETY_CAR_:
		case ALERT_CHEQUERED_FLAG_:
			return filter == AV_EVENT_;
		case ALERT_MESSAGE_ACCIDENT_:
			return filter == AV_INCIDENT_ || filter == AV_EVENT_;
			
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
	[self SetTextColour:defaultTextColour];
	[self SetBackgroundColour:defaultBackgroundColour];
	
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
			int lap = [[alertData itemAtIndex:dataRow] lap];
			float timeStamp = [[alertData itemAtIndex:dataRow] timeStamp];
			
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
			return [[alertData itemAtIndex:dataRow] description];
		}
		case 3:
		{
			return [[alertData itemAtIndex:dataRow] focus];
		}
		case 4:
		{
			return [[alertData itemAtIndex:dataRow] focus2];
		}
		default:
		{
			return @"";
		}
	}
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	[self SetBackgroundColour:defaultBackgroundColour];
	
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
		case ALERT_MESSAGE_ACCIDENT_:
			return [UIImage imageNamed:@"AlertAccident.png"];
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

