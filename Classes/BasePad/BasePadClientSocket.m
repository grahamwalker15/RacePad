//
//  BasePadClientSocket.m
//  BasePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadClientSocket.h"
#import "BasePadDataHandler.h"
#import "BasePadCoordinator.h"
#import "BasePadDatabase.h"

@implementation BasePadClientSocket

- (void) Connected 
{
 	const char *deviceID = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] UTF8String];
	const char *deviceName = [[[UIDevice currentDevice]name] UTF8String];
	int messageLength = 4 * sizeof(uint32_t) + strlen (deviceID) + strlen (deviceName);
	char *buf = malloc(messageLength);
	char *b = buf;
	
	[self pushBuffer: &b Int:messageLength];
	[self pushBuffer: &b Int:BPCS_DEVICE_ID];
	[self pushBuffer: &b String:deviceID];
	[self pushBuffer: &b String:deviceName];
	
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
	
	[[BasePadCoordinator Instance] Connected];
}

- (void) Disconnected:(bool) atConnect
{
	[[BasePadCoordinator Instance] Disconnected:atConnect];
}

- (void) SimpleCommand: (int) command
{
	uint32_t int_data[2];
	int_data[0] =  htonl(8);
	int_data[1] =  htonl(command);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 2);
	[self SendData: data];
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

- (DataHandler *) constructDataHandler
{
	return [[BasePadDataHandler alloc] init];
}

- (void)RequestVersion
{
	[self SimpleCommand:BPCS_REQUEST_VERSION];
}

- (void)RequestUIImages
{
	[self SimpleCommand:BPCS_REQUEST_UI_IMAGES];
}

- (void) acceptPushData :(BOOL) send
{
	int messageLength = 1 + sizeof(uint32_t) * 2;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(BPCS_ACCEPT_PUSH_DATA);
	buf [sizeof(uint32_t) * 2] = send == YES?1:0;
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

- (void) stopStreams
{
	[self SimpleCommand:BPCS_STOP_STREAMS];
}

- (void) cancelDownload
{
	[self SimpleCommand:BPCS_CANCEL_DOWNLOAD];
}

- (void)SynchroniseTime
{
	[self SimpleCommand:BPCS_SYNCHRONISE_TIME];
}

- (void)goLive
{
	[self SimpleCommand:BPCS_GO_LIVE];
}

- (void)SetReferenceTime :(float) reference_time
{
	uint32_t int_data[3];
	int_data[0] =  htonl(12);
	int_data[1] =  htonl(BPCS_SET_REFERENCE_TIME);
	float *t = (float *)int_data + 2;
	*t = reference_time;
	int_data[2] = htonl(int_data[2]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 3);
	[self SendData: data];
	CFRelease(data);
}

- (void) SetPlaybackRate:(float)rate
{
	uint32_t int_data[3];
	int_data[0] =  htonl(12);
	int_data[1] =  htonl(BPCS_SET_PLAYBACK_RATE);
	float *r = (float *)int_data + 2;
	*r = rate;
	int_data[2] = htonl(int_data[2]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) &int_data, sizeof(uint32_t) * 3);
	[self SendData: data];
	CFRelease(data);
}

- (void) StreamCommentary :(NSString *) driver
{
	int messageLength = [driver length] + sizeof(uint32_t) * 3;
	unsigned char *buf = malloc(messageLength);
	int *iData = (int *)buf;
	
	iData[0] = htonl(messageLength);
	iData[1] = htonl(BPCS_STREAM_COMMENTARY);
	iData[2] = htonl([driver length]);
	memcpy(buf + sizeof(uint32_t) * 3, [driver UTF8String], [driver length]);
	CFDataRef data = CFDataCreate (NULL, (const UInt8 *) buf, messageLength);
	[self SendData: data];
	CFRelease(data);
	free (buf);
}

@end
