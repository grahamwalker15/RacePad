//
//  MatchPadClientSocket.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadClientSocket.h"
#import "MatchPadDataHandler.h"
#import "MatchPadCoordinator.h"
#import "MatchPadDatabase.h"
#import "Pitch.h"

@implementation MatchPadClientSocket

- (void)RequestEvent
{
	[self SimpleCommand:MPCS_REQUEST_EVENT];
}

- (void) StreamCommentary :(NSString *) driver
{
	int messageLength = [driver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_STREAM_COMMENTARY);
	iData[2] = htonl([driver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)RequestPitch
{
	[self SimpleCommand:MPCS_REQUEST_PITCH];
}

- (void)StreamPitch
{
	[self SimpleCommand:MPCS_STREAM_PITCH];
}

- (DataHandler *) constructDataHandler
{
	return [[MatchPadDataHandler alloc] init];
}

@end
