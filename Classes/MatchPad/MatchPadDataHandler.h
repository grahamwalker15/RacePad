//
//  MatchPadDataHandler.h
//  MatchPad
//
//  Created by MarkRiches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadDataHandler.h"

#define MATCH_PAD_INTERFACE_VERSION 1

enum ServerCommands {
	MPSC_VERSION_ = BPSC_VERSION_, // 1
	MPSC_EVENT_,				// 2
	MPSC_WHOLE_PLAYER_STATS_,	// 3
	MPSC_UPDATE_PLAYER_STATS_,	// 3
	MPSC_IMAGE_LIST_ITEM_ = BPSC_IMAGE_LIST_ITEM_,	// 8
	MPSC_FILE_START_ = BPSC_FILE_START_,			// 9
	MPSC_FILE_CHUNK_ = BPSC_FILE_CHUNK_,			// 10
	MPSC_FILE_END_ = BPSC_FILE_END_,				// 11
	MPSC_PROJECT_START_ = BPSC_PROJECT_START_,		// 12
	MPSC_ACCEPT_PUSH_DATA_ = BPSC_ACCEPT_PUSH_DATA_,// 14
	MPSC_CANCEL_PROJECT_ = BPSC_CANCEL_PROJECT_,	// 15
	MPSC_COMPLETE_PROJECT_ = BPSC_COMPLETE_PROJECT_,// 16
	MPSC_PROJECT_RANGE_ = BPSC_PROJECT_RANGE_,		// 22
	MPSC_HTML_FILE_ = BPSC_HTML_FILE_,			// 23
	MPSC_LIVE_TIME_ = BPSC_LIVE_TIME_,			// 38
	MPSC_SPONSOR_ = BPSC_SPONSOR_,				// 41
	MPSC_TIME_SYNC_ = BPSC_TIME_SYNC_,			// 42
	MPSC_NO_ACTION_ = BPSC_NO_ACTION_,			// 45
	MPSC_PITCH_,								// 46
	MPSC_SCORE_,								// 47
	MPSC_TEAMS_,								// 48
};

@interface MatchPadDataHandler : BasePadDataHandler
{
}

- (void) handleCommand:(int) command;

@end
