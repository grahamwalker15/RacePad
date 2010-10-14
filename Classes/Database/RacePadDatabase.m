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
	trackMap = [[TrackMap alloc] init];
	imageListStore = [[ImageListStore alloc] init];
	
	return self;
}

- (void) dealloc
{
	[driverListData release];
	[trackMap release];
	[imageListStore release];
	
	[super dealloc];
}

- (TableData *)driverListData
{
	return driverListData;
}

- (TrackMap	*)trackMap
{
	return trackMap;
}

- (ImageListStore *)imageListStore
{
	return imageListStore;
}

@end
