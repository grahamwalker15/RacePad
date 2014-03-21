//
//  BasePadDataHandler.h
//  BasePad
//
//  Created by MarkRiches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataHandler.h"

enum BaseServerCommands {
	BPSC_VERSION_ = 1,
	BPSC_IMAGE_LIST_ITEM_ = 8,
	BPSC_FILE_START_,			// 9
	BPSC_FILE_CHUNK_,			// 10
	BPSC_FILE_END_,				// 11
	BPSC_PROJECT_START_,		// 12
	BPSC_ACCEPT_PUSH_DATA_ = 14,
	BPSC_CANCEL_PROJECT_,		// 15
	BPSC_COMPLETE_PROJECT_,		// 16
	BPSC_PROJECT_RANGE_ = 22,
	BPSC_HTML_FILE_,			// 23
	BPSC_LIVE_TIME_ = 38,
	BPSC_SPONSOR_ = 41,
	BPSC_TIME_SYNC_,			// 42
	BPSC_NO_ACTION_ = 45,
};

@interface BasePadDataHandler : DataHandler
{
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

- (bool) okVersion;

- (int) inqTime;
- (void) setTime: (int) time;
- (void) update: (int ) time;

- (void) handleCommand;
- (void) handleCommand:(int) command;

@end
