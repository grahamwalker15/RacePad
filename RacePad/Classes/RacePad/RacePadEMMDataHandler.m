//
//  RacePadEMMDataHandler.m
//  RacePad
//
//  Created by Gareth Griffith on 10/13/15.
//  Copyright 2015 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadEMMDataHandler.h"
#import "DataStream.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TrackMap.h"

@implementation RacePadEMMDataHandler

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (bool) okVersion
{
	return true;
}

- (void)handleCommand
{
	TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
	[track_map updateCarsFromEMMStream:stream];
	[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
}

@end
