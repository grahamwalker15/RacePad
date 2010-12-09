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

@synthesize eventName;
@synthesize driverListData;
@synthesize leaderBoardData;
@synthesize driverData;
@synthesize trackMap;
@synthesize imageListStore;
@synthesize pitWindow;
@synthesize alertData;
@synthesize rcMessages;
@synthesize telemetry;
@synthesize driverNames;
@synthesize racePrediction;
@synthesize resultData;

- (RacePadDatabase *)init
{
	driverListData = [[TableData alloc] init];
	leaderBoardData = [[TableData alloc] init];
	driverData = [[TableData alloc] init];
	trackMap = [[TrackMap alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	pitWindow = [[PitWindow alloc] init];
	alertData = [[AlertData alloc] init];
	rcMessages = [[AlertData alloc] init];
	telemetry = [[Telemetry alloc] init];
	driverNames = [[DriverNames alloc] init];
	racePrediction = [[RacePrediction alloc] init];
	resultData = [[TableData alloc] init];
	
	return self;
}

- (void) dealloc
{
	[driverListData release];
	[leaderBoardData release];
	[driverData release];
	[trackMap release];
	[imageListStore release];
	[pitWindow release];
	[alertData release];
	[rcMessages release];
	[telemetry release];
	[driverNames release];
	[racePrediction release];
	[resultData release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[rcMessages release];
	[alertData release];
	[racePrediction release];
	alertData = [[AlertData alloc] init];
	rcMessages = [[AlertData alloc] init];
	racePrediction = [[RacePrediction alloc] init];
}

@end
