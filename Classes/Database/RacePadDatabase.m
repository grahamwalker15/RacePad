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
@synthesize telemetry;
@synthesize driverNames;

- (RacePadDatabase *)init
{
	driverListData = [[TableData alloc] init];
	leaderBoardData = [[TableData alloc] init];
	driverData = [[TableData alloc] init];
	trackMap = [[TrackMap alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	pitWindow = [[PitWindow alloc] init];
	alertData = [[AlertData alloc] init];
	telemetry = [[Telemetry alloc] init];
	driverNames = [[DriverNames alloc] init];
	
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
	[telemetry release];
	
	[super dealloc];
}

@end
