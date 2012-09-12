//
//  RacePadDatabase.m
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RacePadDatabase.h"

@implementation RacePadDatabase

static RacePadDatabase *instance = nil;

+ (RacePadDatabase *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

@synthesize driverListData;
@synthesize leaderBoardData;
@synthesize driverData;
@synthesize midasStandingsData;
@synthesize driverGapInfo;
@synthesize trackMap;
@synthesize pitWindow;
@synthesize alertData;
@synthesize rcMessages;
@synthesize commentary;
@synthesize telemetry;
@synthesize driverNames;
@synthesize driverInfo;
@synthesize racePrediction;
@synthesize competitorData;
@synthesize headToHead;
@synthesize midasVotingData;

@synthesize session;

- (RacePadDatabase *)init
{
	if ( [super init] == self )
	{
		session = RPD_SESSION_RACE_;
		driverListData = [[TableData alloc] init];
		leaderBoardData = [[TableData alloc] init];
		driverData = [[TableData alloc] init];
		midasStandingsData = [[TableData alloc] init];
		driverGapInfo = [[DriverGapInfo alloc] init];
		trackMap = [[TrackMap alloc] init];
		pitWindow = [[PitWindow alloc] init];
		alertData = [[AlertData alloc] init];
		rcMessages = [[AlertData alloc] init];
		commentary = [[CommentaryData alloc] init];
		telemetry = [[Telemetry alloc] init];
		driverNames = [[DriverNames alloc] init];
		driverInfo = [[DriverInfo alloc] init];
		racePrediction = [[RacePrediction alloc] init];
		competitorData = [[TableData alloc] init];
		headToHead = [[HeadToHead alloc] init];
		midasVotingData = [[TableData alloc] init];
		
		[driverInfo fillWithDefaultData];
	}

	return self;
}

- (void) dealloc
{
	[driverListData release];
	[leaderBoardData release];
	[driverData release];
	[midasStandingsData release];
	[driverGapInfo release];
	[trackMap release];
	[pitWindow release];
	[alertData release];
	[rcMessages release];
	[commentary release];
	[telemetry release];
	[driverNames release];
	[racePrediction release];
	[competitorData release];
	[headToHead release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[alertData release];
	[rcMessages release];
	[commentary release];
	[racePrediction release];
	
	session = RPD_SESSION_RACE_;
	
	alertData = [[AlertData alloc] init];
	rcMessages = [[AlertData alloc] init];
	commentary = [[CommentaryData alloc] init];
	racePrediction = [[RacePrediction alloc] init];

	[headToHead clearStaticData];
}

@end
