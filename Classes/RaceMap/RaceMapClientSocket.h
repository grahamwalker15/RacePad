//
//  RaceMapClientSocket.h
//  RacePad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadClientSocket.h"

enum ClientCommands {
	RPCS_REQUEST_VERSION = BPCS_REQUEST_VERSION,
	RPCS_REQUEST_EVENT,				// 2
	RPCS_REQUEST_TRACK_MAP,			// 3
	RPCS_SET_REFERENCE_TIME = BPCS_SET_REFERENCE_TIME,	// 4
	RPCS_REQUEST_TIMING_PAGE,		// 5
	RPCS_STREAM_TIMING_PAGE,		// 6
	RPCS_STREAM_CARS,				// 7
	RPCS_REQUEST_UI_IMAGES = BPCS_REQUEST_UI_IMAGES, // 8
	RPCS_REQUEST_CARS,				// 9
	RPCS_REQUEST_DRIVER_VIEW = 13,
	RPCS_ACCEPT_PUSH_DATA = BPCS_ACCEPT_PUSH_DATA, // 14
	RPCS_STOP_STREAMS = BPCS_STOP_STREAMS, // 15
	RPCS_CANCEL_DOWNLOAD = BPCS_CANCEL_DOWNLOAD, // 16
	RPCS_REQUEST_PIT_WINDOW_BASE,	// 17
	RPCS_REQUEST_PIT_WINDOW,		// 18
	RPCS_STREAM_PIT_WINDOW,			// 19
	RPCS_GO_LIVE = BPCS_GO_LIVE,	// 20
	RPCS_REQUEST_LEADER_BOARD,		// 21
	RPCS_STREAM_LEADER_BOARD,		// 22
	RPCS_RACE_PREDICTION,			// 23
	RPCS_DEVICE_ID = BPCS_DEVICE_ID, // 24
	RPCS_REQUEST_PREDICTION,		// 25
	RPCS_REQUEST_GAME_VIEW,			// 26
	RPCS_STREAM_GAME_VIEW,			// 27
	RPCS_CHECK_USER_NAME,			// 28
	RPCS_REQUEST_TELEMETRY,			// 29
	RPCS_STREAM_TELEMETRY,			// 30
	RPCS_SYNCHRONISE_TIME = BPCS_SYNCHRONISE_TIME, // 31
	RPCS_STREAM_COMMENTARY = BPCS_STREAM_COMMENTARY, // 32
	RPCS_REQUEST_DRIVER_GAP_INFO,	// 33
	RPCS_STREAM_DRIVER_GAP_INFO,	// 34
	RPCS_SET_PLAYBACK_RATE = BPCS_SET_PLAYBACK_RATE, // 35
	RPCS_REQUEST_HEAD_TO_HEAD,		// 36
	RPCS_STREAM_HEAD_TO_HEAD,		// 37
	RPCS_REQUEST_STANDINGS_VIEW,		// 38
	RPCS_STREAM_STANDINGS_VIEW,		// 39
	RPCS_REQUEST_DRIVER_VOTING,		// 40
	RPCS_STREAM_DRIVER_VOTING,		// 41
	RPCS_DRIVER_THUMBS_UP,          // 42
	RPCS_DRIVER_THUMBS_DOWN,		// 43
	RPCS_CLIENT_METRIC,             // 44
	RPCS_STREAM_DRIVER_VIEW,		// 45
	RPCS_REQUEST_TIMING_PAGE_1,		// 46
	RPCS_STREAM_TIMING_PAGE_1,		// 47
	RPCS_REQUEST_TIMING_PAGE_2,		// 48
	RPCS_STREAM_TIMING_PAGE_2,		// 49
};

@interface RaceMapClientSocket : BasePadClientSocket
{
}

- (void) RequestEvent;
- (void) RequestTrackMap;
- (void) RequestTimingPage;
- (void) StreamTimingPage;
- (void) RequestTimingPage1;
- (void) StreamTimingPage1;
- (void) RequestTimingPage2;
- (void) StreamTimingPage2;
- (void) RequestStandingsView;
- (void) StreamStandingsView;
- (void) RequestLeaderBoard;
- (void) StreamLeaderBoard;
- (void) RequestCars;
- (void) StreamCars;
- (void) requestDriverView :(NSString *) driver;
- (void) StreamDriverView :(NSString *) driver;
- (void) RequestPitWindowBase;
- (void) RequestPitWindow;
- (void) StreamPitWindow;
- (void) RequestTelemetry;
- (void) StreamTelemetry;
- (void) RequestDriverGapInfo:(NSString *) driver;
- (void) StreamDriverGapInfo:(NSString *) driver;
- (void) StreamTrackProfile;
- (void) RequestTrackProfile;
- (void) RequestHeadToHead:(NSString *) driver0 Driver1: (NSString *) driver1;
- (void) StreamHeadToHead:(NSString *) driver0 Driver1: (NSString *) driver1;

@end
