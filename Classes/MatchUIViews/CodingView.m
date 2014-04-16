//
//  CodingView.m
//  MatchPad
//
//  Created by Simon Cuff on 15/04/2014.
//
//

#import "CodingView.h"

#import "MatchPadDatabase.h"
#import "TableData.h"
#import "AlertData.h"

@implementation CodingView

@synthesize defaultBackgroundColour;
@synthesize defaultTextColour;

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
		[self SetBaseColour:white_];
		[self setDefaultTextColour:black_];
		[self setDefaultBackgroundColour:white_];
		[self setStandardRowHeight:28];
	}
	
    return self;
}

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
			return 290;
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
	if ( filter == CV_ALL_ )
		return true;
	
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	int type = [[codingData itemAtIndex:row] type];
	
	if ( filter == CV_FOLLOW_ )
	{
		return false;
	}
	
	switch (type)
	{
		case ALERT_PERIOD_:
			return filter == CV_PERIOD_;
		case ALERT_PLAYER_:
			return filter == CV_PLAYER_;
		case ALERT_GOAL_:
		case ALERT_MISS_:
		case ALERT_POST_:
		case ALERT_SAVED_:
			return filter == CV_GOAL_;
		case ALERT_FREE_KICK_TAKEN_:
		case ALERT_CORNER_KICK_TAKEN_:
		case ALERT_PENALTY_TAKEN_:
		case ALERT_FREE_KICK_:
		case ALERT_CORNER_:
		case ALERT_OFFSIDE_:
		case ALERT_PENALTY_:
			return filter == CV_KICK_;
		case ALERT_YELLOW_CARD_:
		case ALERT_SECOND_YELLOW_:
		case ALERT_RED_CARD_:
			return filter == CV_CARD_;
			
		default:
			return filter == CV_OTHER_;
	}
}

- (int) RowCount
{
	int count = 0;
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	if ( filter == CV_ALL_ )
		return [codingData itemCount];
	
	for (int i = 0 ; i < [codingData itemCount] ; i++)
		if ( [self includeRow:i] )
			count++;
	
	return count;
}

- (int) filteredRowToDataRow:(int) row
{
	if ( filter == CV_ALL_ )
		return row;
	
	int filteredRow = 0;
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	for (int i = 0 ; i < [codingData itemCount] ; i++)
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
	
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	int dataRow = [self filteredRowToDataRow:row];
    
	switch (col)
	{
		case 0:
		{
			return @"";
		}
		case 1:
		{
			return [[codingData itemAtIndex:dataRow] description];
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
	
	AlertData * codingData = [[MatchPadDatabase Instance] codingData];
	int dataRow = [self filteredRowToDataRow:row];
	int type = [[codingData itemAtIndex:dataRow] type];
    
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


