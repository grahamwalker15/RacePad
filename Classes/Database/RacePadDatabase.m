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
@synthesize driverGapInfo;
@synthesize trackMap;
@synthesize trackProfile;
@synthesize imageListStore;
@synthesize pitWindow;
@synthesize alertData;
@synthesize rcMessages;
@synthesize commentary;
@synthesize commentaryFor;
@synthesize telemetry;
@synthesize driverNames;
@synthesize driverInfo;
@synthesize racePrediction;
@synthesize competitorData;

- (RacePadDatabase *)init
{
	driverListData = [[TableData alloc] init];
	leaderBoardData = [[TableData alloc] init];
	driverData = [[TableData alloc] init];
	driverGapInfo = [[DriverGapInfo alloc] init];
	trackMap = [[TrackMap alloc] init];
	trackProfile = [[TrackProfile alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	pitWindow = [[PitWindow alloc] init];
	alertData = [[AlertData alloc] init];
	rcMessages = [[AlertData alloc] init];
	commentary = [[CommentaryData alloc] init];
	telemetry = [[Telemetry alloc] init];
	driverNames = [[DriverNames alloc] init];
	driverInfo = [[DriverInfo alloc] init];
	racePrediction = [[RacePrediction alloc] init];
	competitorData = [[TableData alloc] init];
	
	[driverInfo fillWithDefaultData];

	return self;
}

- (void) dealloc
{
	[driverListData release];
	[leaderBoardData release];
	[driverData release];
	[driverGapInfo release];
	[trackMap release];
	[trackProfile release];
	[imageListStore release];
	[pitWindow release];
	[alertData release];
	[rcMessages release];
	[commentary release];
	[telemetry release];
	[driverNames release];
	[racePrediction release];
	[competitorData release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[alertData release];
	[rcMessages release];
	[commentary release];
	commentaryFor = nil;
	[racePrediction release];
	alertData = [[AlertData alloc] init];
	rcMessages = [[AlertData alloc] init];
	commentary = [[CommentaryData alloc] init];
	racePrediction = [[RacePrediction alloc] init];
}

@end
