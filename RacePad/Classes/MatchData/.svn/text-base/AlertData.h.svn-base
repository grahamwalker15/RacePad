//
//  AlertData.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

enum AlertTypes
{
	// N.B. MUST MATCH MESSAGE TYPE DEFINIITIONS IN RACEWATCH MatchGame::MatchMessage
	ALERT_PERIOD_,
	ALERT_PLAYER_,
	ALERT_GOAL_,
	ALERT_FREE_KICK_,
	ALERT_CORNER_,
	ALERT_YELLOW_CARD_,
	ALERT_SECOND_YELLOW_,
	ALERT_RED_CARD_,
	ALERT_OFFSIDE_,
	ALERT_FREE_KICK_TAKEN_,
	ALERT_CORNER_KICK_TAKEN_,
	ALERT_PENALTY_,
	ALERT_PENALTY_TAKEN_,
	ALERT_MISS_,
	ALERT_POST_,
	ALERT_SAVED_,
} ;

@interface AlertDataItem : NSObject
{
	int type;
	float time_stamp;
	NSString * description;	
}

@property (nonatomic) int type;
@property (nonatomic) float timeStamp;
@property (nonatomic, retain) NSString * description;	

- (AlertDataItem *) initWithStream:(DataStream*)stream;

@end

@interface AlertData : NSObject
{
	NSMutableArray * alerts; 
}

- (int) itemCount;
- (AlertDataItem *) itemAtIndex:(int)index;

- (void) loadData : (DataStream *) stream;

- (void) clearAll;

@end
