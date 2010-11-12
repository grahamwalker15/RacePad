//
//  RacePadClientSocket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "Socket.h"

enum ClientCommands {
	RPCS_REQUEST_VERSION = 1,
	RPCS_REQUEST_EVENT, // 2
	RPCS_REQUEST_TRACK_MAP, // 3
	RPCS_SET_REFERENCE_TIME, // 4
	RPCS_REQUEST_TIMING_PAGE, // 5
	RPCS_STREAM_TIMING_PAGE, // 6
	RPCS_STREAM_CARS, // 7
	RPCS_REQUEST_DRIVER_HELMETS, // 8
	RPCS_REQUEST_CARS, // 9
	RPCS_REQUEST_DRIVER_VIEW = 13,
	RPCS_ACCEPT_PUSH_DATA, // 14
	RPCS_STOP_STREAMS, // 15
	RPCS_CANCEL_DOWNLOAD, // 16
	RPCS_REQUEST_PIT_WINDOW_BASE, // 17
	RPCS_REQUEST_PIT_WINDOW, // 18
	RPCS_STREAM_PIT_WINDOW, // 19
	RPCS_GO_LIVE, // 20
};

@interface RacePadClientSocket : Socket
{
}

- (void) RequestVersion;
- (void) RequestEvent;
- (void) RequestTrackMap;
- (void) SetReferenceTime:(float)reference_time;
- (void) goLive;
- (void) RequestTimingPage;
- (void) StreamTimingPage;
- (void) RequestCars;
- (void) StreamCars;
- (void) RequestDriverHelmets;
- (void) requestDriverView :(NSString *) driver;
- (void) acceptPushData :(BOOL) send;
- (void) stopStreams;
- (void) cancelDownload;
- (void) RequestPitWindowBase;
- (void) RequestPitWindow;
- (void) StreamPitWindow;

@end
