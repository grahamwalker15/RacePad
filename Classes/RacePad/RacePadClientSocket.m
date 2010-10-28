//
//  RacePadClientSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadClientSocket.h"
#import "RacePadDataHandler.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
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

- (void)RequestVersion
{
	[self SimpleCommand:1];
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

- (void) requestDriverView :(NSString *) driver
{
	int messageLength = [driver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(13);
	iData[2] = htonl([driver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void) acceptPushData :(BOOL) send
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(14);
	buf [sizeof(uint32_t) * 2] = send == YES?1:0;
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (DataHandler *) constructDataHandler
{
	return [[RacePadDataHandler alloc] init];
}

@end
