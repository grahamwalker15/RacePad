//
//  RacePadDataHandler.h
//  RacePad
//
//  Created by MarkRiches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataHandler.h"

#define RACE_PAD_INTERFACE_VERSION 11

enum ServerCommands {
	RPSC_VERSION_ = 1,
	RPSC_EVENT_,				// 2
	RPSC_TRACK_MAP_,			// 3
	RPSC_WHOLE_TIMING_PAGE_ = 5,
	RPSC_UPDATE_TIMING_PAGE_,	// 6
	RPSC_CARS_,					// 7
	RPSC_IMAGE_LIST_ITEM_,		// 8
	RPSC_FILE_START_,			// 9
	RPSC_FILE_CHUNK_,			// 10
	RPSC_FILE_END_,				// 11
	RPSC_PROJECT_START_,		// 12
	RPSC_DRIVER_VIEW_,			// 13
	RPSC_ACCEPT_PUSH_DATA_,		// 14
	RPSC_CANCEL_PROJECT_,		// 15
	RPSC_COMPLETE_PROJECT_,		// 16
	RPSC_LAP_COUNT_,			// 17
	RPSC_LAP_COUNTER_,			// 18
	RPSC_PIT_WINDOW_BASE_,		// 19
	RPSC_PIT_WINDOW_,			// 20
	RPSC_TRACK_STATE_,			// 21
	RPSC_PROJECT_RANGE_,		// 22
	RPSC_HTML_FILE_,			// 23
	RPSC_TELEMETRY_,			// 24
	RPSC_DRIVER_NAMES_,			// 25
	RPSC_WHOLE_LEADER_BOARD_,	// 26
	RPSC_UPDATE_LEADER_BOARD_,	// 27
	RPSC_RC_MESSAGES_,			// 28
	RPSC_ALERTS_,				// 29
	RPSC_RETURN_PREDICTION_,	// 30
	RPSC_GAME_STATUS_ = 33,
	RPSC_WHOLE_COMPETITOR_VIEW_,	// 34
	RPSC_UPDATE_COMPETITOR_VIEW_,	// 35
	RPSC_REGISTERED_USER_,		// 36
	RPSC_BAD_USER_,				// 37
	RPSC_LIVE_TIME_,			// 38
	RPSC_RED_COMMENTARY_,		// 39
	RPSC_BLUE_COMMENTARY_,		// 40
	RPSC_SPONSOR_,				// 41
	RPSC_TIME_SYNC_,			// 42
	RPSC_COMMENTARY_,			// 43
	RPSC_DRIVER_GAP_INFO_,		// 44
	RPSC_NO_ACTION_,			// 45
};

@interface RacePadDataHandler : DataHandler
{
	
	int versionNumber;
	int nextTime;
	
	FILE *saveFile;
	NSString *saveFileName;
	int saveChunks;
	int nextChunk;
	double sizeDownloaded;
	
	int *index;
	int indexSize;
	int indexBase;
	int indexStep;
}

- (id) init;
- (id) initWithPath: (NSString *)archive SessionPrefix:(NSString *)sessionPrefix SubIndex:(NSString *)chunk;
- (int) inqTime;
- (void) setTime: (int) time;
- (void) update: (int ) time;

- (void) handleCommand;

@end
