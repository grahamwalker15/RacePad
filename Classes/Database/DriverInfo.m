//
//  DriverInfo.m
//  RacePad
//
//  Created by Gareth Griffith on 2/7/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverInfo.h"

@implementation DriverInfoRecord

@synthesize abbr;

@synthesize age;
@synthesize races;
@synthesize championships;
@synthesize wins;
@synthesize poles;
@synthesize fastestLaps;
@synthesize points;
@synthesize lastPos;
@synthesize lastPoints;

- (id) initWithName:(NSString *)name Age:(int)ageIn Races:(int)racesIn Championships:(int)championshipsIn Wins:(int)winsIn Poles:(int)polesIn FastestLaps:(int)fastestLapsIn Points:(float)pointsIn LastPos:(int)lastPosIn LastPoints:(float)lastPointsIn
{
	if(self = [super init])
	{
		abbr = [name retain];
		
		age = ageIn;
		races = racesIn;
		championships = championshipsIn;
		wins = winsIn;
		poles = polesIn;
		fastestLaps = fastestLapsIn;
		points = pointsIn;;
		lastPos = lastPosIn;
		lastPoints = lastPointsIn;
	}	
	return self;
}

- (void) dealloc
{
	[abbr release];	
	[super dealloc];
}

@end

@implementation DriverInfo

@synthesize count;

- (id)init
{
	if(self = [super init])
	{
		drivers = [[NSMutableArray alloc] init];
		count = 0;
	}
	
	return self;
}

- (void) dealloc
{
	[drivers release];	
	[super dealloc];
}

- (void)addDriverWithName:(NSString *)name Age:(int)ageIn Races:(int)racesIn Championships:(int)championshipsIn Wins:(int)winsIn Poles:(int)polesIn FastestLaps:(int)fastestLapsIn Points:(float)pointsIn LastPos:(int)lastPosIn LastPoints:(float)lastPointsIn

{
	DriverInfoRecord * driverInfo = [[DriverInfoRecord alloc] initWithName:name Age:ageIn Races:racesIn Championships:championshipsIn Wins:winsIn Poles:polesIn FastestLaps:fastestLapsIn Points:pointsIn LastPos:lastPosIn LastPoints:lastPointsIn];
	
	[drivers addObject:driverInfo];
	count++;
	
	[driverInfo release];
}

- (DriverInfoRecord *)driverInfoByAbbName:(NSString *) abbName
{
	for ( int i = 0; i < count; i++ )
	{
		DriverInfoRecord * driverInfo = [drivers objectAtIndex : i];
		if ( [driverInfo.abbr isEqualToString:abbName] )
			return driverInfo;
	}
	
	return nil;
}

- (void) fillWithDefaultData
{
	[self addDriverWithName:@"BUT" Age:31 Races:189 Championships:1 Wins:9 Poles:7 FastestLaps:3 Points:541 LastPos:5 LastPoints:214];
	[self addDriverWithName:@"HAM" Age:26 Races:71 Championships:1 Wins:14 Poles:18 FastestLaps:8 Points:496 LastPos:4 LastPoints:240];
	[self addDriverWithName:@"MSC" Age:42 Races:268 Championships:7 Wins:91 Poles:68 FastestLaps:76 Points:1441 LastPos:9 LastPoints:72];
	[self addDriverWithName:@"ROS" Age:25 Races:62 Championships:0 Wins:0 Poles:0 FastestLaps:2 Points:217.5 LastPos:7 LastPoints:142];
	[self addDriverWithName:@"VET" Age:23 Races:62 Championships:1 Wins:10 Poles:15 FastestLaps:6 Points:381 LastPos:1 LastPoints:256];
	[self addDriverWithName:@"WEB" Age:34 Races:157 Championships:0 Wins:6 Poles:6 FastestLaps:6 Points:411.5 LastPos:3 LastPoints:242];
	[self addDriverWithName:@"MAS" Age:29 Races:133 Championships:0 Wins:11 Poles:15 FastestLaps:12 Points:464 LastPos:6 LastPoints:144];
	[self addDriverWithName:@"ALO" Age:29 Races:158 Championships:2 Wins:26 Poles:20 FastestLaps:18 Points:829 LastPos:2 LastPoints:252];
	[self addDriverWithName:@"BAR" Age:38 Races:303 Championships:0 Wins:11 Poles:14 FastestLaps:17 Points:654 LastPos:10 LastPoints:47];
	[self addDriverWithName:@"HUL" Age:23 Races:19 Championships:0 Wins:0 Poles:1 FastestLaps:0 Points:22 LastPos:14 LastPoints:22];
	[self addDriverWithName:@"KUB" Age:26 Races:76 Championships:0 Wins:1 Poles:1 FastestLaps:1 Points:273 LastPos:8 LastPoints:136];
	[self addDriverWithName:@"PET" Age:26 Races:19 Championships:0 Wins:0 Poles:0 FastestLaps:1 Points:27 LastPos:13 LastPoints:27];
	[self addDriverWithName:@"SUT" Age:28 Races:71 Championships:0 Wins:0 Poles:0 FastestLaps:1 Points:53 LastPos:11 LastPoints:47];
	[self addDriverWithName:@"LIU" Age:29 Races:63 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:26 LastPos:15 LastPoints:21];
	[self addDriverWithName:@"BUE" Age:22 Races:36 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:14 LastPos:16 LastPoints:8];
	[self addDriverWithName:@"ALG" Age:20 Races:27 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:5 LastPos:19 LastPoints:5];
	[self addDriverWithName:@"DLR" Age:39 Races:85 Championships:0 Wins:0 Poles:0 FastestLaps:1 Points:35 LastPos:17 LastPoints:6];
	[self addDriverWithName:@"KOB" Age:24 Races:21 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:35 LastPos:12 LastPoints:32];
	[self addDriverWithName:@"HEI" Age:33 Races:172 Championships:0 Wins:0 Poles:1 FastestLaps:2 Points:225 LastPos:18 LastPoints:6];
	[self addDriverWithName:@"SEN" Age:27 Races:18 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:0 LastPos:23 LastPoints:0];
	[self addDriverWithName:@"CHA" Age:27 Races:10 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:0 LastPos:22 LastPoints:0];
	[self addDriverWithName:@"YAM" Age:28 Races:21 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:0 LastPos:26 LastPoints:0];
	[self addDriverWithName:@"KLI" Age:28 Races:49 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:14 LastPos:27 LastPoints:0];
	[self addDriverWithName:@"TRU" Age:36 Races:238 Championships:0 Wins:1 Poles:4 FastestLaps:1 Points:246.5 LastPos:21 LastPoints:0];
	[self addDriverWithName:@"KOV" Age:31 Races:70 Championships:0 Wins:1 Poles:1 FastestLaps:2 Points:105 LastPos:20 LastPoints:0];
	[self addDriverWithName:@"GLO" Age:28 Races:54 Championships:0 Wins:0 Poles:0 FastestLaps:1 Points:51 LastPos:25 LastPoints:0];
	[self addDriverWithName:@"DIG" Age:26 Races:18 Championships:0 Wins:0 Poles:0 FastestLaps:0 Points:0 LastPos:24 LastPoints:0];
}

@end
