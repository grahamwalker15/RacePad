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
@synthesize driverData;
@synthesize trackMap;
@synthesize imageListStore;
@synthesize pitWindow;
@synthesize alertData;

- (RacePadDatabase *)init
{
	driverListData = [[TableData alloc] init];
	driverData = [[TableData alloc] init];
	trackMap = [[TrackMap alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	pitWindow = [[PitWindow alloc] init];
	alertData = [[AlertData alloc] init];
	
	return self;
}

- (void) dealloc
{
	[driverListData release];
	[driverData release];
	[trackMap release];
	[imageListStore release];
	[pitWindow release];
	
	[super dealloc];
}

@end
