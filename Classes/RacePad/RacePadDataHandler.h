//
//  RacePadDataHandler.h
//  RacePad
//
//  Created by MarkRiches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataHandler.h"

#define RACE_PAD_INTERFACE_VERSION 8

enum ServerCommands {
	RPSC_VERSION_ = 1,
	RPSC_EVENT_, // 2
	RPSC_TRACK_MAP_, // 3
	RPSC_WHOLE_TIMING_PAGE_ = 5,
	RPSC_UPDATE_TIMING_PAGE_, // 6
	RPSC_CARS_, // 7
	RPSC_IMAGE_LIST_ITEM_, // 8
	RPSC_FILE_START_, // 9
	RPSC_FILE_CHUNK_, // 10
	RPSC_FILE_END_, // 11
	RPSC_PROJECT_START_, // 12
	RPSC_DRIVER_VIEW_, // 13
	RPSC_ACCEPT_PUSH_DATA_, // 14
	RPSC_CANCEL_PROJECT_, // 15
	RPSC_COMPLETE_PROJECT_, // 16
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
- (id) initWithPath: (NSString *)path;
- (int) inqTime;
- (void) setTime: (int) time;
- (void) update: (int ) time;

- (void) handleCommand;

@end
