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
#import "PlayerStatsController.h"
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

- (void)RequestScore
{
	[self SimpleCommand:MPCS_REQUEST_SCORE];
}

- (void)StreamScore
{
	[self SimpleCommand:MPCS_STREAM_SCORE];
}

- (void)RequestTeams
{
	[self SimpleCommand:MPCS_REQUEST_TEAMS];
}

- (void)RequestPlayerStats
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_REQUEST_PLAYER_STATS);
	buf[sizeof(uint32_t) * 2] = [[[MatchPadCoordinator Instance] playerStatsController] home];
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)StreamPlayerStats
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_STREAM_PLAYER_STATS);
	buf[sizeof(uint32_t) * 2] = [[[MatchPadCoordinator Instance] playerStatsController] home];
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)RequestPlayerGraph:(int) player GraphType:(unsigned char)graphType
{
	int messageLength = sizeof(uint32_t) * 3 + 1;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_REQUEST_PLAYER_GRAPH);
	iData[2] = htonl(player);
	buf[sizeof(uint32_t) * 3] = graphType;
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)StreamPlayerGraph:(int) player GraphType:(unsigned char)graphType
{
	int messageLength = sizeof(uint32_t) * 3 + 1;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_STREAM_PLAYER_GRAPH);
	iData[2] = htonl(player);
	buf[sizeof(uint32_t) * 3] = graphType;
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (DataHandler *) constructDataHandler
{
	return [[MatchPadDataHandler alloc] init];
}

@end
