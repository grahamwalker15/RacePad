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

- (RacePadDatabase *)init
{
	driverListData = [[TableData alloc] init];
	driverData = [[TableData alloc] init];
	trackMap = [[TrackMap alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	pitWindow = [[PitWindow alloc] init];
	
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

- (TableData *)driverListData
{
	return driverListData;
}

- (TableData *)driverData
{
	return driverData;
}

- (TrackMap	*)trackMap
{
	return trackMap;
}

- (ImageListStore *)imageListStore
{
	return imageListStore;
}

- (PitWindow *)pitWindow
{
	return pitWindow;
}

@end
