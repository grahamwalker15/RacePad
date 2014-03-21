//
//  AlertData.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertData.h"
#import "DataStream.h"
#import "RacePadDataHandler.h"

@implementation AlertDataItem

@synthesize type;
@synthesize timeStamp;
@synthesize lap;
@synthesize focus;
@synthesize focus2;
@synthesize description;
@synthesize confidence;

- (id) initWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn
{
	if(self = [super init])
	{
		type = typeIn;
		lap = lapIn;
		timeStamp = timeStampIn;
		focus = [focusIn retain];
		description = [descriptionIn retain];
		confidence = 5;
	}	   
	
	return self;
}

- (id) initWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn;
{
	if(self = [super init])
	{
		type = typeIn;
		lap = lapIn;
		timeStamp = hIn * 3600.0 + mIn * 60.0 + sIn;
		focus = [focusIn retain];
		description = [descriptionIn retain];
		confidence = 5;
	}	   
	
	return self;
}

- (AlertDataItem *) initWithStream:(DataStream*)stream
{
	type = [stream PopUnsignedChar];
	lap = [stream PopInt];
	timeStamp = [stream PopFloat];
	focus = [[stream PopString] retain];
	focus2 = [[stream PopString] retain];
	description = [[stream PopString] retain];
	if ( stream.versionNumber >= RACE_PAD_COMMENTARY_IMPORTANCE )
		confidence = [stream PopInt];
	else
		confidence = 5;
	
	return self;
}

- (void) dealloc
{
	[description release];
	[focus release];
	[focus2 release];
	[super dealloc];
}

@end

@implementation AlertData

- (id) init
{
	if(self = [super init])
	{
		alerts = [[NSMutableArray alloc] init];
		
		/*
		[self addItemWithType:ALERT_RACE_EVENT_ Lap:1 H:14 M:3 S:30 Focus:@"" Description:@"Race Start"];
		[self addItemWithType:ALERT_INCIDENT_ Lap:1 H:14 M:5 S:24 Focus:@"BAR" Description:@"Collision BAR and ALO"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 H:14 M:5 S:34 Focus:@"BUT" Description:@"BUT overtook MAS at T1"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 H:14 M:5 S:38 Focus:@"BUT" Description:@"BUT overtook VET at T1"];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:2 H:14 M:7 S:3 Focus:@"" Description:@"Safety Car Deployed"];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:3 H:14 M:10 S:40 Focus:@"" Description:@"Safety Car In"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 H:14 M:11 S:03 Focus:@"VET" Description:@"VET overtook KUB at T1"];
		[self addItemWithType:ALERT_INCIDENT_ Lap:17 H:14 M:35 S:22 Focus:@"VET" Description:@"Collision VET and BUT"];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 H:15 M:10 S:01 Focus:@"MSC" Description:@"MSC Pit Stop L34"];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 H:15 M:10 S:05 Focus:@"ROS" Description:@"ROS Pit Stop L34"];
		[self addItemWithType:ALERT_INCIDENT_ Lap:38 H:15 M:17 S:20 Focus:@"ALO" Description:@"Accident ALO"];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:38 H:15 M:17 S:47 Focus:@"" Description:@"Safety Car Deployed"];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:40 H:15 M:24 S:19 Focus:@"" Description:@"Safety Car In"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:40 H:15 M:25 S:2 Focus:@"ROS" Description:@"ROS overtook MSC at T4"];
		[self addItemWithType:ALERT_INCIDENT_ Lap:41 H:15 M:25 S:53 Focus:@"TRU" Description:@"Spin TRU"];
		[self addItemWithType:ALERT_CHEQUERED_FLAG_ Lap:44 H:15 M:32 S:34 Focus:@"" Description:@"Chequered Flag"];
		 */
	}	   
	   
	return self;
}
	   
- (void) dealloc
{
	[alerts release];
	[super dealloc];
}
	   
- (int) itemCount
{
	return [alerts count];
}

- (AlertDataItem *) itemAtIndex:(int)index
{
	if(index >= 0 && index < [alerts count])
		return (AlertDataItem *)[alerts objectAtIndex:index];
	else
		return nil;
}

- (void) addItemWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn
{
	AlertDataItem * newItem = [[AlertDataItem alloc] initWithType:typeIn Lap:lapIn TimeStamp:timeStampIn Focus:focusIn Description:descriptionIn];
	[alerts addObject:newItem];
	[newItem release];
}
				   
- (void) addItemWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(NSString * )focusIn Description:(NSString *)descriptionIn
{
	AlertDataItem * newItem = [[AlertDataItem alloc] initWithType:typeIn Lap:lapIn H:hIn M:mIn S:sIn Focus:focusIn Description:descriptionIn];
	[alerts addObject:newItem];
	[newItem release];
}

- (void) loadData : (DataStream *) stream
{
	int count = [stream PopInt];
	for ( int i = 0; i < count; i++ )
	{
		int index = [stream PopInt];
		AlertDataItem *item = [[AlertDataItem alloc] initWithStream:stream];
		[alerts addObject:item];
		[item release];
	}
}

- (void) clearAll
{
	[alerts removeAllObjects];
}
				   
@end
