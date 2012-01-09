//
//  AlertView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertView.h"

#import "MatchPadDatabase.h"
#import "TableData.h"
#import "AlertData.h"

@implementation AlertView


- (void)dealloc
{
    [super dealloc];
}

-(void) setFilter:(int) type Player:(NSString *)inPlayer
{
	filter = type;
	player = inPlayer;
}

- (void)PrepareData
{
	[super PrepareData];
	[self SetBaseColour:white_];
}

- (int) ColumnCount
{
	return 2;
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
			return 620;
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
		default:
			return SLV_TEXT_CELL_;
	}
}

- (bool) includeRow:(int) row
{
	if ( filter == AV_ALL_ )
		return true;
	
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
	int type = [[alertData itemAtIndex:row] type];
	
	if ( filter == AV_FOLLOW_ )
	{
		return false;
	}
	
	switch (type)
	{
		case ALERT_PERIOD_:
			return filter == AV_PERIOD_;
		case ALERT_PLAYER_:
			return filter == AV_PLAYER_;
		case ALERT_GOAL_:
		case ALERT_MISS_:
		case ALERT_POST_:
		case ALERT_SAVED_:
			return filter == AV_GOAL_;
		case ALERT_FREE_KICK_TAKEN_:
		case ALERT_CORNER_KICK_TAKEN_:
		case ALERT_PENALTY_TAKEN_:
		case ALERT_FREE_KICK_:
		case ALERT_CORNER_:
		case ALERT_OFFSIDE_:
		case ALERT_PENALTY_:
			return filter == AV_KICK_;
		case ALERT_YELLOW_CARD_:
		case ALERT_SECOND_YELLOW_:
		case ALERT_RED_CARD_:
			return filter == AV_CARD_;
			
		default:
			return filter == AV_OTHER_;
	}				
}

- (int) RowCount
{
	int count = 0;
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
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
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
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
	
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
	int dataRow = [self filteredRowToDataRow:row];

	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
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
	
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
	int dataRow = [self filteredRowToDataRow:row];
	int type = [[alertData itemAtIndex:dataRow] type];

	switch (type)
	{
		case ALERT_PERIOD_:
			return [UIImage imageNamed:@"AlertInfo.png"];
		case ALERT_PLAYER_:
			return [UIImage imageNamed:@"AlertPlayer.png"];
		case ALERT_GOAL_:
			return [UIImage imageNamed:@"AlertGoal.png"];
		case ALERT_FREE_KICK_:
			return [UIImage imageNamed:@"AlertFreeKickAwarded.png"];
		case ALERT_PENALTY_:
			return [UIImage imageNamed:@"AlertPenaltyAwarded.png"];
		case ALERT_CORNER_:
			return [UIImage imageNamed:@"AlertCornerAwarded.png"];
		case ALERT_FREE_KICK_TAKEN_:
			return [UIImage imageNamed:@"AlertFreeKick.png"];
		case ALERT_CORNER_KICK_TAKEN_:
			return [UIImage imageNamed:@"AlertCorner.png"];
		case ALERT_PENALTY_TAKEN_:
			return [UIImage imageNamed:@"AlertPenalty.png"];
		case ALERT_OFFSIDE_:
			return [UIImage imageNamed:@"AlertOffside.png"];
		case ALERT_YELLOW_CARD_:
			return [UIImage imageNamed:@"AlertYellowCard.png"];
		case ALERT_SECOND_YELLOW_:
			return [UIImage imageNamed:@"Alert2ndYellow.png"];
		case ALERT_RED_CARD_:
			return [UIImage imageNamed:@"AlertRedCard.png"];
		case ALERT_MISS_:
			return [UIImage imageNamed:@"AlertMiss.png"];
		case ALERT_POST_:
			return [UIImage imageNamed:@"AlertPost.png"];
		case ALERT_SAVED_:
			return [UIImage imageNamed:@"AlertSave.png"];
		default:
			return [UIImage imageNamed:@"AlertInfo.png"];
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

