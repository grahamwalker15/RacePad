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

- (void) sendMetric:(int) metric
{
	int messageLength = sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_CLIENT_METRIC);
	iData[2] = htonl(metric);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

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

- (void)RequestStandingsView
{
	[self SimpleCommand:RPCS_STREAM_STANDINGS_VIEW];
}

- (void)StreamStandingsView
{
	[self SimpleCommand:RPCS_STREAM_STANDINGS_VIEW];
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
	[self SendData: data];
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
	[self SendData: data];
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
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

- (void)StreamDriverView:(NSString *) driver
{
	int messageLength = [driver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_STREAM_DRIVER_VIEW);
	iData[2] = htonl([driver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

- (void)RequestHeadToHead:(NSString *) driver0 Driver1: (NSString *) driver1
{
	NSString * sentDriver0;
	if(driver0 && [driver0 length] > 0)
		sentDriver0 = driver0;
	else
		sentDriver0 = @"-";	// Will result in nothing coming back
	NSString * sentDriver1;
	if(driver1 && [driver1 length] > 0)
		sentDriver1 = driver1;
	else
		sentDriver1 = @"-";	// Will result in nothing coming back
	
	int messageLength = [sentDriver0 length] + [sentDriver1 length] + sizeof(uint32_t) * 4;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_REQUEST_HEAD_TO_HEAD);
	iData[2] = htonl([sentDriver0 length]);
	memcpy(buf + sizeof(uint32_t) * 3, [sentDriver0 UTF8String], [sentDriver0 length]);
	int *d = (int *) (buf + sizeof(uint32_t) * 3 + [sentDriver0 length]);
	*d = htonl([sentDriver1 length]);
	memcpy(buf + sizeof(uint32_t) * 4 + [sentDriver0 length], [sentDriver1 UTF8String], [sentDriver1 length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

- (void)StreamHeadToHead:(NSString *) driver0 Driver1: (NSString *) driver1
{
	NSString * sentDriver0;
	if(driver0 && [driver0 length] > 0)
		sentDriver0 = driver0;
	else
		sentDriver0 = @"-";	// Will result in nothing coming back
	NSString * sentDriver1;
	if(driver1 && [driver1 length] > 0)
		sentDriver1 = driver1;
	else
		sentDriver1 = @"-";	// Will result in nothing coming back
	
	int messageLength = [sentDriver0 length] + [sentDriver1 length] + sizeof(uint32_t) * 4;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(RPCS_STREAM_HEAD_TO_HEAD);
	iData[2] = htonl([sentDriver0 length]);
	memcpy(buf + sizeof(uint32_t) * 3, [sentDriver0 UTF8String], [sentDriver0 length]);
	int *d = (int *) (buf + sizeof(uint32_t) * 3 + [sentDriver0 length]);
	*d = htonl([sentDriver1 length]);
	memcpy(buf + sizeof(uint32_t) * 4 + [sentDriver0 length], [sentDriver1 UTF8String], [sentDriver1 length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
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
	[self SendData: data];
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
	[self SendData: data];
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

- (void) RequestDriverVoting
{
	[self SimpleCommand:RPCS_REQUEST_DRIVER_VOTING];
}

- (void) StreamDriverVoting
{
	[self SimpleCommand:RPCS_STREAM_DRIVER_VOTING];
}

- (void) DriverThumbsUp:(NSString *) driver
{
	if(driver && [driver length] > 0)
    {
        int messageLength = [driver length] + sizeof(uint32_t) * 3;
        unsigned char *buf = malloc(messageLength);
        int *iData = (int *)buf;
        
        iData[0] = htonl(messageLength);
        iData[1] = htonl(RPCS_DRIVER_THUMBS_UP);
        iData[2] = htonl([driver length]);
        memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
        CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
        [self SendData: data];
        CFRelease(data);
        free (buf);
	};
}

- (void) DriverThumbsDown:(NSString *) driver
{
	if(driver && [driver length] > 0)
    {
        int messageLength = [driver length] + sizeof(uint32_t) * 3;
        unsigned char *buf = malloc(messageLength);
        int *iData = (int *)buf;
        
        iData[0] = htonl(messageLength);
        iData[1] = htonl(RPCS_DRIVER_THUMBS_DOWN);
        iData[2] = htonl([driver length]);
        memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
        CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
        [self SendData: data];
        CFRelease(data);
        free (buf);
	};
}


- (DataHandler *) constructDataHandler
{
	return [[RacePadDataHandler alloc] init];
}

@end
