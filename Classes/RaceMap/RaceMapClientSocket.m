//
//  RacePadClientSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapClientSocket.h"
#import "RaceMapDataHandler.h"
#import "RaceMapCoordinator.h"
#import "RaceMapData.h"
#import "TrackMap.h"

@implementation RaceMapClientSocket

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

- (void)RequestDistanceMap
{
	[self SimpleCommand:RPCS_REQUEST_DISTANCE_MAP];
}

- (void)RequestTLAMap
{
	[self SimpleCommand:RPCS_REQUEST_TLA_MAP];
}

- (void)RequestTimingPage
{
	[self SimpleCommand:RPCS_REQUEST_TIMING_PAGE];
}

- (void)StreamTimingPage
{
	[self SimpleCommand:RPCS_STREAM_TIMING_PAGE];
}

- (void)RequestTimingPage1
{
	[self SimpleCommand:RPCS_REQUEST_TIMING_PAGE_1];
}

- (void)StreamTimingPage1
{
	[self SimpleCommand:RPCS_STREAM_TIMING_PAGE_1];
}

- (void)RequestTimingPage2
{
	[self SimpleCommand:RPCS_REQUEST_TIMING_PAGE_2];
}

- (void)StreamTimingPage2
{
	[self SimpleCommand:RPCS_STREAM_TIMING_PAGE_2];
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
