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

- (id) init
{
	[super init];
	
	saveFile = nil;
	index = nil;
	return self;
}

- (id) initWithPath: (NSString *)path
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];
	NSString *fileName = [folder stringByAppendingString:path];
	
	if ( [super initWithPath:fileName] == self )
	{
		saveFile = nil;
		index = nil;

		versionNumber = 0;
		nextTime = 0;
		
		if ( [stream canPop:4] )
		{
			versionNumber = [stream PopInt];
			
			if ( versionNumber != RACE_PAD_INTERFACE_VERSION )
			{
				[self closeStream];
			}
			else
			{
				if ( [stream canPop:4] )
				{
					nextTime = [stream PopInt];
			
					NSString *indexName = [fileName stringByReplacingOccurrencesOfString:@".rpf" withString:@".rpi"];
					FILE *indexFile = fopen ( [indexName UTF8String], "rb" );
					indexSize = 0;
					if ( indexFile != nil )
					{
						int t;
						fread(&t, 1, sizeof(int), indexFile);
						int indexVersion = htonl ( t );
						
						if ( indexVersion == versionNumber )
						{
							fread(&t, 1, sizeof(int), indexFile);
							indexBase = htonl ( t );

							fread(&t, 1, sizeof(int), indexFile);
							indexStep = htonl ( t );

							fread(&t, 1, sizeof(int), indexFile);
							int indexSizeHint = htonl ( t );
							
							index = (int *)malloc(indexSizeHint * sizeof(int));
							
							int i = 0;
							while (!feof(indexFile))
							{
								fread(&t, 1, sizeof(int), indexFile);
								if (i >= indexSizeHint)
								{
									indexSizeHint += indexSizeHint * 0.1;
									index = (int *)realloc(index, indexSizeHint * sizeof(int));
								}
								index[i++] = htonl ( t );
								indexSize = i;
							}
						}
						
						fclose(indexFile);
					}
				}
			}
		}
	}
	
	return self;
}

- (void) dealloc
{
	if ( index )
		free ( index );
	
	[super dealloc];
}

- (int) inqTime
{
	return nextTime;
}

- (void) setTime: (int) time
{
	int filePos = sizeof ( int ); // To skip the version number
	if ( indexSize > 0 )
	{
		int secsOffset = time / 1000 - indexBase;
		int indexOffset = secsOffset / indexStep;
		if ( indexOffset >= indexSize )
			indexOffset = indexSize - 1;
		filePos = index[indexOffset];
	}
	
	[self setStreamPos: filePos];
	if ( [stream canPop:4] )
	{
		nextTime = [stream PopInt];
	}
	else
	{
		nextTime = 0;
	}
	
	[self update:time];
}

- (void) update:(int)time
{
	// add a fraction onto the time, so we end up with aliasing
	time += 0.02;
	
	while (nextTime > 0 && time >= nextTime)
	{
		[self handleCommand];
		if ( [stream canPop:4] )
		{
			nextTime = [stream PopInt];
		}
		else
		{
			nextTime = 0;
		}
	}
}

- (void)handleCommand
{
	int command = [stream PopInt];
	switch (command)
	{
		case RPSC_VERSION_:
			versionNumber = [stream PopInt];
			if ( versionNumber == RACE_PAD_INTERFACE_VERSION )
				[[RacePadCoordinator Instance] serverConnected:YES];
			else
				[[RacePadCoordinator Instance] serverConnected:NO];
			break;
		
		case RPSC_EVENT_:
		{
			RacePadDatabase *database = [RacePadDatabase Instance];
			NSString *string = [stream PopString];
			[ database setEventName:string];
			break;
		}
		case RPSC_TRACK_MAP_: // Track Map
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map loadTrack:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
		case RPSC_WHOLE_TIMING_PAGE_: // Timing Page 1 (whole page)
		{
			
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
		case RPSC_UPDATE_TIMING_PAGE_: // Timing Page 1 (updates)
		{
			TableData *driver_list = [[RacePadDatabase Instance] driverListData];
			[driver_list updateData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
			
		case RPSC_CARS_: // Track Map Cars
		{
			TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
			[track_map updateCars:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
			
		case RPSC_IMAGE_LIST_ITEM_:
		{
			ImageListStore *imageListStore = [[RacePadDatabase Instance] imageListStore];
			[imageListStore loadItem:stream];
			break;
		}
		case RPSC_FILE_START_: // Project File start
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
		case RPSC_FILE_CHUNK_: // Project File chunk
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
		case RPSC_FILE_END_: // Project File complete
		{
			assert ( nextChunk == saveChunks );
			if ( saveFile != nil )
				fclose(saveFile);
			saveFile = nil;
			break;
		}
		case RPSC_PROJECT_START_: // Project Folder
		{
			NSString *folder = [stream PopString];
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			NSString *fileName = [docsFolder stringByAppendingString:@"/"];
			fileName = [fileName stringByAppendingString:folder];
			
			NSFileManager *fm = [[NSFileManager alloc]init];
			[fm setDelegate:self];
			[fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:NULL];
			break;
		}
		case RPSC_DRIVER_VIEW_: // Driver view
		{
			
			TableData *driver = [[RacePadDatabase Instance] driverData];
			[driver loadData:stream];
			
			// TESTING MR
			// Redraw the timing view
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			// TESTING END
			break;
		}
		case RPSC_ACCEPT_PUSH_DATA_: // Accept Push Data
		{
			NSString *event = [stream PopString];
			NSString *session = [stream PopString];
			[[RacePadCoordinator Instance] acceptPushData:event Session:session];
			break;
		}
		default:
			break;
	}
}

-  (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path
{
	return YES;
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error removingItemAtPath:(NSString *)path
{
	return NO;
}

@end
