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

- (void) SimpleCommand: (int) command
{
	uint32_t int_data[2];
	int_data[0] =  htonl(8);
	int_data[1] =  htonl(command);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 2);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
}

-(void) pushBuffer:(char **)buf Int:(int)v
{
	int *b = (int *)(*buf);
	*b = htonl(v);
	*buf += sizeof(int);
}

-(void) pushBuffer:(char **)buf String:(const char *)v
{
	int l = 0;
	if ( v )
		l = strlen(v);
	[self pushBuffer:buf Int:l];
	memcpy(*buf, v, l);
	*buf += l;
}

- (void) Connected 
{
	const char *deviceID = [[[UIDevice currentDevice]uniqueIdentifier] UTF8String];
	const char *deviceName = [[[UIDevice currentDevice]name] UTF8String];
	int messageLength = 4 * sizeof(uint32_t) + strlen (deviceID) + strlen (deviceName);
	char *buf = malloc(messageLength);
	char *b = buf;
	
	[self pushBuffer: &b Int:messageLength];
	[self pushBuffer: &b Int:RPCS_DEVICE_ID];
	[self pushBuffer: &b String:deviceID];
	[self pushBuffer: &b String:deviceName];
	
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
	
	[[RacePadCoordinator Instance] Connected];
}

- (void) Disconnected:(bool) atConnect
{
	[[RacePadCoordinator Instance] Disconnected:atConnect];
}

- (void)RequestVersion
{
	[self SimpleCommand:RPCS_REQUEST_VERSION];
}

- (void)RequestEvent
{
	[self SimpleCommand:RPCS_REQUEST_EVENT];
}

- (void)RequestTrackMap
{
	[self SimpleCommand:RPCS_REQUEST_TRACK_MAP];
}

- (void)SetReferenceTime :(float) reference_time;
{
	uint32_t int_data[3];
	int_data[0] =  htonl(12);
	int_data[1] =  htonl(RPCS_SET_REFERENCE_TIME);
	float *t = (float *)int_data + 2;
	*t = reference_time;
	int_data[2] = htonl(int_data[2]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 3);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
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

- (void)RequestUIImages
{
	[self SimpleCommand:RPCS_REQUEST_UI_IMAGES];
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

- (void) acceptPushData :(BOOL) send
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_ACCEPT_PUSH_DATA);
	buf [sizeof(uint32_t) * 2] = send == YES?1:0;
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	CFSocketSendData (socket_ref_, nil, data, 0);
	CFRelease(data);
	free (buf);
}

- (void) stopStreams
{
	[self SimpleCommand:RPCS_STOP_STREAMS];
}

- (void) cancelDownload
{
	[self SimpleCommand:RPCS_CANCEL_DOWNLOAD];
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

- (void)goLive
{
	[self SimpleCommand:RPCS_GO_LIVE];
}

- (void)RequestTelemetry
{
	[self SimpleCommand:RPCS_REQUEST_TELEMETRY];
}

- (void)StreamTelemetry
{
	[self SimpleCommand:RPCS_STREAM_TELEMETRY];
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

- (DataHandler *) constructDataHandler
{
	return [[RacePadDataHandler alloc] init];
}

@end
