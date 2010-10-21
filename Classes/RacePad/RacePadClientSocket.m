//
//  RacePadClientSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadClientSocket.h"
#import "RacePadDataHandler.h"
#include "RacePadCoordinator.h"
#include "RacePadDatabase.h"
#import "TrackMap.h"

@implementation RacePadClientSocket

- (void) Connected 
{
	[[RacePadCoordinator Instance] Connected];
}

- (void) SimpleCommand: (int) command
{
	uint32_t int_data[2];
	int_data[0] =  htonl(8);
	int_data[1] =  htonl(command);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 2);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
}

- (void)RequestEvent
{
	[self SimpleCommand:2];
}

- (void)RequestTrackMap
{
	[self SimpleCommand:3];
}

- (void)SetReferenceTime :(float) reference_time;
{
	uint32_t int_data[3];
	int_data[0] =  htonl(12);
	int_data[1] =  htonl(4);
	float *t = (float *)int_data + 2;
	*t = reference_time;
	int_data[2] = htonl(int_data[2]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 3);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
}

- (void)RequestTimingPage
{
	[self SimpleCommand:5];
}

- (void)StreamTimingPage
{
	[self SimpleCommand:6];
}

- (void)StreamCars
{
	[self SimpleCommand:7];
}

- (void)RequestDriverHelmets
{
	[self SimpleCommand:8];
}

- (DataHandler *) constructDataHandler {
	return [[RacePadDataHandler alloc] init];
}

@end
