//
//  BasePadClientSocket.h
//  BasePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "Socket.h"

enum BaseClientCommands {
	BPCS_REQUEST_VERSION = 1,
	BPCS_SET_REFERENCE_TIME = 4,
	BPCS_REQUEST_UI_IMAGES = 8,
	BPCS_ACCEPT_PUSH_DATA = 14,
	BPCS_STOP_STREAMS = 15,
	BPCS_CANCEL_DOWNLOAD = 16,
	BPCS_GO_LIVE = 20,
	BPCS_DEVICE_ID = 24,
	BPCS_SYNCHRONISE_TIME = 31,
	BPCS_STREAM_COMMENTARY = 32,
	BPCS_SET_PLAYBACK_RATE = 35,
};

@interface BasePadClientSocket : Socket
{
}

- (void) SimpleCommand: (int) command;
-(void) pushBuffer:(char **)buf Int:(int)v;
-(void) pushBuffer:(char **)buf String:(const char *)v;
- (DataHandler *) constructDataHandler;

- (void) RequestVersion;
- (void) goLive;
- (void) SetReferenceTime:(float)reference_time;
- (void) SetPlaybackRate:(float)rate;
- (void) RequestUIImages;
- (void) acceptPushData :(BOOL) send;
- (void) stopStreams;
- (void) cancelDownload;
- (void) SynchroniseTime;
- (void) StreamCommentary :(NSString *) driver;

@end
