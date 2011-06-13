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

- (void)RequestEvent
{
	[self SimpleCommand:RPCS_REQUEST_EVENT];
}

- (void)RequestTrackMap
{
	[self SimpleCommand:RPCS_REQUEST_TRACK_MAP];
}

- (void)RequestTimingPage
{
	[self SimpleCommand:RPCS_REQUEST_TIMING_PAGE];
}

- (void)StreamTimingPage
{
	[self SimpleCommand:RPCS_STREAM_TIMING_PAGE];
}

- (void)RequestLeaderBoard
{
	[self SimpleCommand:RPCS_REQUEST_LEADER_BOARD];
}

- (void)StreamLeaderBoard
{
	[self SimpleCommand:RPCS_STREAM_LEADER_BOARD];
}

- (void)RequestCars
{
	[self SimpleCommand:RPCS_REQUEST_CARS];
}

- (void)StreamCars
{
	[self SimpleCommand:RPCS_STREAM_CARS];
}

- (void) requestDriverView :(NSString *) driver
{
	int messageLength = [driver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_REQUEST_DRIVER_VIEW);
	iData[2] = htonl([driver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)RequestPitWindowBase
{
	[self SimpleCommand:RPCS_REQUEST_PIT_WINDOW_BASE];
}

- (void)RequestPitWindow
{
	[self SimpleCommand:RPCS_REQUEST_PIT_WINDOW];
}

- (void)StreamPitWindow
{
	[self SimpleCommand:RPCS_STREAM_PIT_WINDOW];
}

- (void)RequestTelemetry
{
	[self SimpleCommand:RPCS_REQUEST_TELEMETRY];
}

- (void)StreamTelemetry
{
	[self SimpleCommand:RPCS_STREAM_TELEMETRY];
}

- (void)RequestDriverGapInfo:(NSString *) driver
{
	NSString * sentDriver;
	if(driver && [driver length] > 0)
		sentDriver = driver;
	else
		sentDriver = @"-";	// Will result in nothing coming back

	int messageLength = [sentDriver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_REQUEST_DRIVER_GAP_INFO);
	iData[2] = htonl([sentDriver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [sentDriver UTF8String], [sentDriver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)StreamDriverGapInfo:(NSString *) driver
{
	NSString * sentDriver;
	if(driver && [driver length] > 0)
		sentDriver = driver;
	else
		sentDriver = @"-";	// Will result in nothing coming back
	
	int messageLength = [sentDriver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_STREAM_DRIVER_GAP_INFO);
	iData[2] = htonl([sentDriver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [sentDriver UTF8String], [sentDriver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

-(void) sendPrediction: (NSString *)userName Command:(int)command
{
	RacePrediction *racePrediction = [[RacePadDatabase Instance] racePrediction];
	const char *user = [userName UTF8String];
	int count = racePrediction.count;
	int *prediction = [racePrediction prediction];
	
	int messageLength = (count + 4) * sizeof(uint32_t);
	if ( user )
		messageLength += strlen(user);
	char *buf = malloc(messageLength);
	char *b = buf;
	
	[self pushBuffer: &b Int:messageLength];
	[self pushBuffer: &b Int:command];
	[self pushBuffer: &b String:user];
	[self pushBuffer: &b Int:count];
	for ( int i = 0; i < count; i++ )
		[self pushBuffer: &b Int:prediction[i]];
	
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

-(void) sendPrediction
{
	RacePrediction *racePrediction = [[RacePadDatabase Instance] racePrediction];
	[self sendPrediction:racePrediction.user Command:RPCS_RACE_PREDICTION];
}

- (void)requestPrediction:(NSString *)name
{
	const char *user = [name UTF8String];
	
	int messageLength = 3 * sizeof(uint32_t);
	if ( user )
		messageLength += strlen(user);
	char *buf = malloc(messageLength);
	char *b = buf;
	
	[self pushBuffer: &b Int:messageLength];
	[self pushBuffer: &b Int:RPCS_REQUEST_PREDICTION];
	[self pushBuffer: &b String:user];

	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void)RequestGameView
{
	[self SimpleCommand:RPCS_REQUEST_GAME_VIEW];
}

- (void)StreamGameView
{
	[self SimpleCommand:RPCS_STREAM_GAME_VIEW];
}

-(void) checkUserName: (NSString *)name
{
	[self sendPrediction:name Command:RPCS_CHECK_USER_NAME];
}

- (void)RequestTrackProfile
{
	[self SimpleCommand:RPCS_REQUEST_CARS];
}

- (void)StreamTrackProfile
{
	[self SimpleCommand:RPCS_STREAM_CARS];
}

- (DataHandler *) constructDataHandler
{
	return [[RacePadDataHandler alloc] init];
}

@end
