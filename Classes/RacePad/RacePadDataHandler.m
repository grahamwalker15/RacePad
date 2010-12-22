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
#include "RacePadTitleBarController.h"
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
	NSString *fileName = [folder stringByAppendingPathComponent:path];
	
	if ( self = [super initWithPath:fileName] )
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
			[[RacePadTitleBarController Instance] setEventName:string];
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
		case RPSC_WHOLE_LEADER_BOARD_: // Leader Board (whole page)
		{
			
			TableData *leader_board = [[RacePadDatabase Instance] leaderBoardData];
			[leader_board loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LEADER_BOARD_VIEW_];
			break;
		}
		case RPSC_UPDATE_LEADER_BOARD_: // Leader Board (updates)
		{
			TableData *leader_board = [[RacePadDatabase Instance] leaderBoardData];
			[leader_board updateData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LEADER_BOARD_VIEW_];
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
			NSString *fileName = [docsFolder stringByAppendingPathComponent:folder];
			fileName = [fileName stringByAppendingPathComponent:name];
			
			saveFile = fopen ( [fileName UTF8String], "wb" );
			saveFileName = [fileName retain];
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
			sizeDownloaded += size / (1024 * 1024.0);
			[[RacePadCoordinator Instance] projectDownloadProgress:(int)sizeDownloaded];
			break;
		}
		case RPSC_FILE_END_: // Project File complete
		{
			assert ( nextChunk == saveChunks );
			if ( saveFile != nil )
			{
				fclose(saveFile);
				[saveFileName release];
				saveFileName = nil;
			}
			saveFile = nil;
			break;
		}
		case RPSC_PROJECT_START_: // Project Folder
		{
			NSString *folder = [stream PopString];
			NSString *eventName = [stream PopString];
			NSString *sessionName = [stream PopString];
			int sizeInMB = [stream PopInt];
			
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			NSString *fileName = [docsFolder stringByAppendingPathComponent:folder];
			
			NSFileManager *fm = [[NSFileManager alloc]init];
			[fm setDelegate:self];
			[fm createDirectoryAtPath:fileName withIntermediateDirectories:YES attributes:nil error:NULL];
			[fm release];
			[[RacePadCoordinator Instance] projectDownloadStarting:eventName SessionName:sessionName SizeInMB:sizeInMB];
			
			sizeDownloaded = 0;
			break;
		}
		case RPSC_DRIVER_VIEW_: // Driver view
		{
			TableData *driver = [[RacePadDatabase Instance] driverData];
			[driver loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LAP_LIST_VIEW_];
			break;
		}
		case RPSC_ACCEPT_PUSH_DATA_: // Accept Push Data
		{
			NSString *event = [stream PopString];
			NSString *session = [stream PopString];
			[[RacePadCoordinator Instance] acceptPushData:event Session:session];
			break;
		}
		case RPSC_CANCEL_PROJECT_: // Cancel Project Send
		{
			if ( saveFile != nil )
			{
				fclose(saveFile);
				NSFileManager *fm = [[NSFileManager alloc]init];
				[fm setDelegate:self];
				[fm removeItemAtPath:saveFileName error:NULL];
				[fm release];
				[saveFileName release];
				saveFileName = nil;
			}
			saveFile = nil;
			[[RacePadCoordinator Instance] projectDownloadCancelled];
			break;
		}
		case RPSC_COMPLETE_PROJECT_: // Cancel Project Send
		{
			[[RacePadCoordinator Instance] projectDownloadComplete];
			break;
		}
		case RPSC_LAP_COUNT_:
		{
			int count = [stream PopInt];
			[[RacePadTitleBarController Instance] setLapCount:count];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LAP_COUNT_VIEW_];
			break;
		}
		case RPSC_LAP_COUNTER_:
		{
			int lap = [stream PopInt];
			[[RacePadTitleBarController Instance] setCurrentLap:lap];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LAP_COUNT_VIEW_];
			break;
		}
		case RPSC_PIT_WINDOW_BASE_: // Pit Window Base
		{
			PitWindow *pitWindow = [[RacePadDatabase Instance] pitWindow];
			[pitWindow loadBase:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_PIT_WINDOW_VIEW_];
			break;
		}
		case RPSC_PIT_WINDOW_: // Pit Window
		{
			PitWindow *pitWindow = [[RacePadDatabase Instance] pitWindow];
			[pitWindow load:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_PIT_WINDOW_VIEW_];
			break;
		}
		case RPSC_TRACK_STATE_:
		{
			int state = [stream PopInt];
			[[RacePadTitleBarController Instance] setTrackState:state];
			break;
		}
		case RPSC_PROJECT_RANGE_:
		{
			int start = [stream PopInt];
			int end = [stream PopInt];
			[[RacePadCoordinator Instance] setProjectRange:start End:end];
			break;
		}
		case RPSC_HTML_FILE_:
		{
			NSString *name = [stream PopString];

			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			NSString *folder = [docsFolder stringByAppendingPathComponent:@"LocalHTML"];
			NSString *fileName = [folder stringByAppendingPathComponent:name];

			NSFileManager *fm = [[NSFileManager alloc]init];
			[fm setDelegate:self];
			[fm createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL];
			
			int size = [stream PopInt];
			NSData *data = [stream PopData:size];

			[fm createFileAtPath:fileName contents:data attributes:nil];
			
			[fm release];
			break;
		}
		case RPSC_TELEMETRY_: // Telemetry Data
		{
			Telemetry *telemetry = [[RacePadDatabase Instance] telemetry];
			[telemetry load:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_TELEMETRY_VIEW_];
			break;
		}
		case RPSC_DRIVER_NAMES_: // Driver Names
		{
			DriverNames *driverNames = [[RacePadDatabase Instance] driverNames];
			[driverNames loadData:stream];
			[[RacePadCoordinator Instance] updateDriverNames];
			break;
		}
		case RPSC_RC_MESSAGES_: // Race Control Messages
		{
			AlertData *rc_messages = [[RacePadDatabase Instance] rcMessages];
			[rc_messages loadData:stream];
			break;
		}
		case RPSC_ALERTS_: // Alerts
		{
			AlertData *alertData = [[RacePadDatabase Instance] alertData];
			[alertData loadData:stream];
			break;
		}
		case RPSC_RETURN_PREDICTION_: // Race prediction for this user
		{
			[[[RacePadDatabase Instance] racePrediction] load:stream];
			[[RacePadCoordinator Instance] updatePrediction];
			break;
		}
		case RPSC_GAME_STATUS_: // Game Start Time
		{
			[[[RacePadDatabase Instance] racePrediction] loadStatus:stream];
			[[RacePadCoordinator Instance] updatePrediction];
			break;
		}
		case RPSC_WHOLE_COMPETITOR_VIEW_: // Competitor View (whole page)
		{
			
			TableData *resultData = [[RacePadDatabase Instance] competitorData];
			[resultData loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_GAME_VIEW_];
			break;
		}
		case RPSC_UPDATE_COMPETITOR_VIEW_: // Competitor View (updates)
		{
			TableData *resultData = [[RacePadDatabase Instance] competitorData];
			[resultData updateData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_GAME_VIEW_];
			break;
		}
		case RPSC_REGISTERED_USER_: // New user accepted
		{
			[[RacePadCoordinator Instance] registeredUser];
			break;
		}
		case RPSC_BAD_USER_: // New user accepted
		{
			[[RacePadCoordinator Instance] badUser];
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
