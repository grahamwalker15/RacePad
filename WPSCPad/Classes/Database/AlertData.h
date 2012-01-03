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
	// N.B. MUST MATCH MESSAGE TYPE DEFINIITIONS IN RACEWATCH rc_message_record.h
	ALERT_RC_MESSAGE_,
	ALERT_RACE_EVENT_,
	ALERT_INCIDENT_,
	ALERT_OVERTAKE_,
	ALERT_SAFETY_CAR_,
	ALERT_GREEN_FLAG_,
	ALERT_YELLOW_FLAG_,
	ALERT_RED_FLAG_,
	ALERT_CHEQUERED_FLAG_,
	ALERT_PIT_STOP_,
	ALERT_YELLOW_VIOLATION_,
	ALERT_OVERTAKE_SC_,
	ALERT_CAR_STOPPED_,
	ALERT_CAR_CONTINUED_,
	ALERT_SC_SPEEDING_,
	ALERT_SC_VIOLATION_,
	ALERT_OFF_TRACK_,
	ALERT_YELLOW_SPEEDING_,
	ALERT_USER_EVENT_,
	ALERT_LAP_COMPLETE_,
	ALERT_INFO_,
	ALERT_PIT_INSIGHT_,
	ALERT_BLOCKING_,
	ALERT_DRIVER_EVENT_,
	ALERT_BOOKMARK_,
	ALERT_PERFORMANCE_GREEN_,
	ALERT_PERFORMANCE_PURPLE_
} ;

@interface AlertDataItem : NSObject
{
	int type;
	NSString *  focus;
	NSString *  focus2;
	int lap;
	float time_stamp;
	NSString * description;	
	int confidence;
}

@property (nonatomic) int type;
@property (nonatomic, retain) NSString *  focus;
@property (nonatomic, retain) NSString *  focus2;
@property (nonatomic) int lap;
@property (nonatomic) float timeStamp;
@property (nonatomic, retain) NSString * description;	
@property (nonatomic) int confidence;

- (id) initWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn;
- (id) initWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn;
- (AlertDataItem *) initWithStream:(DataStream*)stream;

@end

@interface AlertData : NSObject
{
	NSMutableArray * alerts; 
}

- (int) itemCount;
- (AlertDataItem *) itemAtIndex:(int)index;

- (void) addItemWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn;
- (void) addItemWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn;

- (void) loadData : (DataStream *) stream;

- (void) clearAll;

@end
