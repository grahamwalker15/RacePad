//
//  RacePadEMMSocket.m
//  RacePad
//
//  Created by Gareth Griffith on 10/13/15.
//  Copyright 2015 SBG Racing Services Ltd. All rights reserved.
//


#import "RacePadEMMSocket.h"
#import "RacePadEMMDataHandler.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TrackMap.h"

@implementation RacePadEMMSocket

// This is a connection to the very reduced EMM feed. Most methods do nothing. The streaming of cars is automatic.

- (DataHandler *) constructDataHandler
{
	return [[RacePadEMMDataHandler alloc] init];
}

- (void) Connected 
{	
	[[BasePadCoordinator Instance] Connected];
	[[BasePadCoordinator Instance] setServerConnected:YES];
	
	[self setDataTimeout:100.0];
	[self setRequiresTransferSize:false];
}

- (void) Disconnected:(bool) atConnect
{
	[[BasePadCoordinator Instance] Disconnected:atConnect];
}

- (void) SimpleCommand: (int) command
{
}

-(void) pushBuffer:(char **)buf Int:(int)v
{
}

-(void) pushBuffer:(char **)buf String:(const char *)v
{
}

- (void)RequestVersion
{
}

- (void)RequestUIImages
{
}

- (void) acceptPushData :(BOOL) send
{
}

- (void) stopStreams
{
}

- (void) cancelDownload
{
}

- (void)SynchroniseTime
{
}

- (void)goLive
{
}

- (void)SetReferenceTime :(float) reference_time
{
}

- (void) SetPlaybackRate:(float)rate
{
}

- (void) StreamCommentary :(NSString *) driver
{
}

@end
