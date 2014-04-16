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
#import "PhysicalStatsController.h"
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

- (void)RequestPhysicalStats
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_REQUEST_PHYSICAL_STATS);
	buf[sizeof(uint32_t) * 2] = [[[MatchPadCoordinator Instance] physicalStatsController] home];
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)StreamPhysicalStats
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(MPCS_STREAM_PHYSICAL_STATS);
	buf[sizeof(uint32_t) * 2] = [[[MatchPadCoordinator Instance] physicalStatsController] home];
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}


- (void)RequestTeamStats
{
	[self SimpleCommand:MPCS_REQUEST_TEAM_STATS];
}

- (void)StreamTeamStats
{
	[self SimpleCommand:MPCS_STREAM_TEAM_STATS];
}

- (void)RequestCoding
{
	[self SimpleCommand:MPCS_REQUEST_CODING];
}

- (void)StreamCoding
{
	[self SimpleCommand:MPCS_STREAM_CODING];
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

- (void)RequestPossession
{
	[self SimpleCommand:MPCS_REQUEST_POSSESSION];
}

- (void)StreamPossession
{
	[self SimpleCommand:MPCS_STREAM_POSSESSION];
}

- (void)RequestMoves
{
	[self SimpleCommand:MPCS_REQUEST_MOVES];
}

- (void)StreamMoves
{
	[self SimpleCommand:MPCS_STREAM_MOVES];
}

- (void)RequestBall
{
	[self SimpleCommand:MPCS_REQUEST_BALL];
}

- (void)StreamBall
{
	[self SimpleCommand:MPCS_STREAM_BALL];
}

- (void)RequestPositions
{
	[self SimpleCommand:MPCS_REQUEST_POSITIONS];
}

- (void)StreamPositions
{
	[self SimpleCommand:MPCS_STREAM_POSITIONS];
}

- (DataHandler *) constructDataHandler
{
	return [[MatchPadDataHandler alloc] init];
}

@end
