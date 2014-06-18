//
//  RacePadDatabase.m
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RaceMapData.h"

@implementation RaceMapData

static RaceMapData *instance = nil;

+ (RaceMapData *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

@synthesize driverListData;
@synthesize leaderBoardData;
@synthesize driverData;
@synthesize trackMap;
@synthesize alertData;
@synthesize driverNames;
@synthesize driverInfo;
@synthesize competitorData;
@synthesize timingPage1;
@synthesize timingPage2;

@synthesize session;

- (RaceMapData *)init
{
	if ( self = [super init] )
	{
		session = RPD_SESSION_RACE_;
		driverListData = [[TableData alloc] init];
		leaderBoardData = [[TableData alloc] init];
		driverData = [[TableData alloc] init];
		trackMap = [[TrackMap alloc] init];
		competitorData = [[TableData alloc] init];
		timingPage1 = [[TableData alloc] init];
		timingPage2 = [[TableData alloc] init];
		
		[driverInfo fillWithDefaultData];
	}
	
	return self;
}

- (void) dealloc
{
	[driverListData release];
	[leaderBoardData release];
	[driverData release];
	[trackMap release];
	[alertData release];
	[driverNames release];
	[competitorData release];
	[timingPage1 release];
	[timingPage2 release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[alertData release];
    
	session = RPD_SESSION_RACE_;
	
	alertData = [[RaceMapAlertData alloc] init];
}

@end
