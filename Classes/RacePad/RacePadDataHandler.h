//
//  RacePadDataHandler.h
//  RacePad
//
//  Created by MarkRiches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataHandler.h"

@interface RacePadDataHandler : DataHandler
{
	
	int nextTime;
	
	FILE *saveFile;
	int saveChunks;
	int nextChunk;
	
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
