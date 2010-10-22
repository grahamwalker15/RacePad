//
//  RacePadDataHandler.m
//  RacePad
//
//  Created by Mark Riches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadDataHandler.h"
#import "DataStream.h"
#include "RacePadCoordinator.h"
#include "RacePadDatabase.h"
#import "TrackMap.h"

@implementation RacePadDataHandler

- (id) init {
	[super init];
	
	saveFile = nil;
	index = nil;
	return self;
}

- (id) initWithPath: (NSString *)path {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *fileName = [folder stringByAppendingString:path];
	
	fprintf ( stderr, "Looking for: %s\n", [fileName UTF8String] );
	[super initWithPath:fileName];
	
	saveFile = nil;
	index = nil;

	if ( [stream canPop:4] ) {
		nextTime = [stream PopInt];
	}
	else {
		nextTime = 0;
	}
	
	NSString *indexName = [fileName stringByReplacingOccurrencesOfString:@".rpf" withString:@".rpi"];
	FILE *indexFile = fopen ( [indexName UTF8String], "rb" );
	indexSize = 0;
	if ( indexFile != nil ) {
		int t;
		fread(&t, 1, sizeof(int), indexFile);
		indexBase = htonl ( t );

		fread(&t, 1, sizeof(int), indexFile);
		indexStep = htonl ( t );

		fread(&t, 1, sizeof(int), indexFile);
		int indexSizeHint = htonl ( t );
		
		index = (int *)malloc(indexSizeHint * sizeof(int));
		
		int i = 0;
		while (!feof(indexFile)) {
			fread(&t, 1, sizeof(int), indexFile);
			if (i >= indexSizeHint) {
				indexSizeHint += indexSizeHint * 0.1;
				index = (int *)realloc(index, indexSizeHint * sizeof(int));
			}
			index[i++] = htonl ( t );
			indexSize = i;
		}
		fclose(indexFile);
	}
	
	return self;
}

- (void) dealloc {
	if ( index )
		free ( index );
	[super dealloc];
}

- (int) inqTime {
	return nextTime;
}

- (void) setTime: (int) time {
	int filePos = 0;
	if ( indexSize > 0 )
	{
		int secsOffset = time / 1000 - indexBase;
		int indexOffset = secsOffset / indexStep;
		if ( indexOffset >= indexSize )
			indexOffset = indexSize - 1;
		filePos = index[indexOffset];
	}
	
	[self setStreamPos: filePos];
	if ( [stream canPop:4] ) {
		nextTime = [stream PopInt];
	} else {
		nextTime = 0;
	}
	
	[self update:time];
}

- (void) update: (int) time {
	while (nextTime > 0 && time >= nextTime) {
		[self handleCommand];
		if ( [stream canPop:4] ) {
			nextTime = [stream PopInt];
		} else {
			nextTime = 0;
		}
	}
}

- (void)handleCommand
{
	int command = [stream PopInt];
	switch (command)
	{
		case 1:
			break;
		
		case 2:
		{
			RacePadDatabase *database = [RacePadDatabase Instance];
			NSString *string = [stream PopString];
			[ database setEventName:string];
			break;
		}
		case 3: // Track Map
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map loadTrack:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
		case 4: 
			break;
			
		case 5: // Timing Page 1 (whole page)
		{
			
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
		case 6: // Timing Page 1 (updates)
		{
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list updateData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
			
		case 7: // Track Map Cars
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map updateCars:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
			
		case 8:
		{
			ImageListStore *imageListStore = [[RacePadDatabase Instance] imageListStore];
			[imageListStore loadItem:stream];
			break;
		}
		case 9: // Project File start
		{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			
			NSString *folder = [stream PopString];
			NSString *name = [stream PopString];
			NSString *fileName = [docsFolder stringByAppendingString:@"/"];
			fileName = [fileName stringByAppendingString:folder];
			fileName = [fileName stringByAppendingString:@"/"];
			fileName = [fileName stringByAppendingString:name];
			
			saveFile = fopen ( [fileName UTF8String], "wb" );
			saveChunks = [stream PopInt];
			nextChunk = 0;
			break;
		}
		case 10: // Project File chunk
		{
			int chunk = [stream PopInt];
			assert ( chunk == nextChunk );
			
			nextChunk++;
			int size = [stream PopInt];
			if ( size > 0 )
			{
				unsigned char *buffer = malloc(size);
				[stream PopBuffer:buffer Length:size];
				if ( saveFile != nil )
					fwrite(buffer, 1, size, saveFile);
				free ( buffer );
			}
			break;
		}
		case 11: // Project File complete
		{
			assert ( nextChunk == saveChunks );
			if ( saveFile != nil )
				fclose(saveFile);
			saveFile = nil;
			break;
		}
		case 12: // Project Folder
		{
			NSString *folder = [stream PopString];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			NSString *fileName = [docsFolder stringByAppendingString:@"/"];
			fileName = [fileName stringByAppendingString:folder];
			
			NSFileManager *fm = [[NSFileManager alloc]init];
			[fm setDelegate:self];
			BOOL ok = [fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:NULL];
			break;
		}
		default:
			break;
	}
}

-  (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path {
	return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path {
	return NO;
}

@end
