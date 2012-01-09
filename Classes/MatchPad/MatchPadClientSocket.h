//
//  MatchPadClientSocket.h
//  MatchPad
//
//  Created by Gareth Griffith on 10/5/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadClientSocket.h"

enum ClientCommands {
	MPCS_REQUEST_VERSION = BPCS_REQUEST_VERSION, // 1
	MPCS_REQUEST_EVENT,				// 2
	MPCS_SET_REFERENCE_TIME = BPCS_SET_REFERENCE_TIME,	// 4
	MPCS_REQUEST_PLAYER_STATS,		// 5
	MPCS_STREAM_PLAYER_STATS,		// 6
	MPCS_REQUEST_UI_IMAGES = BPCS_REQUEST_UI_IMAGES, // 8
	MPCS_ACCEPT_PUSH_DATA = BPCS_ACCEPT_PUSH_DATA, // 14
	MPCS_STOP_STREAMS = BPCS_STOP_STREAMS, // 15
	MPCS_CANCEL_DOWNLOAD = BPCS_CANCEL_DOWNLOAD, // 16
	MPCS_GO_LIVE = BPCS_GO_LIVE,	// 20
	MPCS_DEVICE_ID = BPCS_DEVICE_ID, // 24
	MPCS_SYNCHRONISE_TIME = BPCS_SYNCHRONISE_TIME, // 31
	MPCS_STREAM_COMMENTARY = BPCS_STREAM_COMMENTARY, // 32
	MPCS_SET_PLAYBACK_RATE = BPCS_SET_PLAYBACK_RATE, // 35
	MPCS_STREAM_PITCH,				// 36
	MPCS_REQUEST_PITCH,				// 37
	MPCS_STREAM_SCORE,				// 38
	MPCS_REQUEST_SCORE,				// 39
	MPCS_REQUEST_TEAMS,				// 40
	MPCS_REQUEST_PLAYER_GRAPH,		// 41
	MPCS_STREAM_PLAYER_GRAPH,		// 42
	MPCS_REQUEST_POSSESSION,		// 43
	MPCS_STREAM_POSSESSION,			// 44
	MPCS_REQUEST_MOVES,				// 45
	MPCS_STREAM_MOVES,				// 46
	MPCS_REQUEST_BALL,				// 47
	MPCS_STREAM_BALL,				// 48
};

@interface MatchPadClientSocket : BasePadClientSocket
{
}

- (void) RequestEvent;

- (void) RequestPitch;
- (void) StreamPitch;

- (void) RequestScore;
- (void) StreamScore;

- (void) RequestTeams;

- (void) RequestPlayerStats;
- (void) StreamPlayerStats;

- (void) RequestPlayerGraph:(int)player GraphType:(unsigned char)graphType;
- (void) StreamPlayerGraph:(int)player GraphType:(unsigned char)graphType;

- (void) RequestPossession;
- (void) StreamPossession;

- (void) RequestMoves;
- (void) StreamMoves;

- (void) RequestBall;
- (void) StreamBall;

- (void) StreamCommentary :(NSString *) driver;

@end
