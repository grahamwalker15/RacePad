//
//  BasePadDataHandler.m
//  BasePad
//
//  Created by Mark Riches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadDataHandler.h"
#import "DataStream.h"
#import "BasePadCoordinator.h"
#import "BasePadDatabase.h"
#import "BasePadTitleBarController.h"
#import "BasePadSponsor.h"

@implementation BasePadDataHandler

- (id) init
{
	if(self = [super init])
	{	
		saveFile = nil;
		index = nil;
	}
	return self;
}

- (id) initWithPath: (NSString *)archive SessionPrefix:(NSString *)sessionPrefix SubIndex:(NSString *)chunk
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [paths objectAtIndex:0];

	NSString *fName = [sessionPrefix stringByAppendingString:archive];
	NSString *fileName = [folder stringByAppendingPathComponent:fName];
	
	if ( self = [super initWithPath:fileName] )
	{
		saveFile = nil;
		index = nil;

		versionNumber = 0;
		nextTime = 0;
		
		if ( [stream canPop:4] )
		{
			versionNumber = [stream PopInt];
			
			if ( ![self okVersion] )
			{
				[self closeStream];
			}
			else
			{
				[stream setVersionNumber: versionNumber];
				// Now find the index for the specified chunk
				indexSize = 0;

				int indexHome = 0;
				if ( [stream canPop:4] )
					indexHome = [stream PopInt];
				
				int chunkCount = 0;
				[self setStreamPos: indexHome];
				if ( [stream canPop:4] )
				{
					chunkCount = [stream PopInt];
					indexHome += 4;
				}
				
				for ( int ci = 0; ci < chunkCount; ci++ )
				{
					[self setStreamPos: indexHome];
					if ( [stream canPop:4] )
					{
						NSString *chunkName = [stream PopString];
						indexBase = [stream PopInt];
						indexStep = [stream PopInt];
						int indexSizeHint = [stream PopInt];
						
						if ( [chunkName isEqualToString:chunk] )
						{
							index = (int *)malloc(indexSizeHint * sizeof(int));

							for ( int i = 0; i < indexSizeHint; i++ )
							{
								if ( [stream canPop:4] )
								{
									index[i] = [stream PopInt];
									indexSize ++;
								}
								else
									break;
							}
							break;
						}
						else
						{
							indexHome += indexSizeHint * 4 + 16 + [chunkName length];
						}
					}
					else
					{
						break;
					}

				}
				
				if ( indexSize > 0 )
				{
					[stream setPos:index[0]];
					if ( [stream canPop:4] )
					{
						nextTime = [stream PopInt];
				
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

- (bool) okVersion
{
	return false;
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
		int indexOffset = 0;
		if ( indexStep )
		{
			indexOffset = secsOffset / indexStep;
			if ( indexOffset >= indexSize )
				indexOffset = indexSize - 1;
			if ( indexOffset < 0 )
				indexOffset = 0;
		}
		filePos = index[indexOffset];
	
		if ( filePos > 0 )
		{
			[self setStreamPos: filePos];
			if ( [stream canPop:4] )
			{
				nextTime = [stream PopInt];
			}
			else
			{
				nextTime = 0;
			}
		}
		else 
		{
			nextTime = 0;
		}

		[self update:time];
	}
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

- (void) handleCommand
{
	int command = [stream PopInt];

	[self handleCommand:command];
}

- (void)handleCommand:(int) command
{
	switch (command)
	{
		case BPSC_VERSION_:
			versionNumber = [stream PopInt];
			if ( [self okVersion] )
			{
				[stream setVersionNumber:versionNumber];
				[[BasePadCoordinator Instance] setServerConnected:YES];
			}
			else
				[[BasePadCoordinator Instance] setServerConnected:NO];
			break;
					
		case BPSC_IMAGE_LIST_ITEM_:
		{
			ImageListStore *imageListStore = [[BasePadDatabase Instance] imageListStore];
			[imageListStore loadItem:stream];
			break;
		}
		case BPSC_FILE_START_: // Project File start
		{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsFolder = [paths objectAtIndex:0];
			
			NSString *name = [stream PopString];
			NSString *fileName = [docsFolder stringByAppendingPathComponent:name];
			
			saveFile = fopen ( [fileName UTF8String], "wb" );
			saveFileName = [fileName retain];
			saveChunks = [stream PopInt];
			nextChunk = 0;
			break;
		}
		case BPSC_FILE_CHUNK_: // Project File chunk
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
			[[BasePadCoordinator Instance] projectDownloadProgress:(int)sizeDownloaded];
			break;
		}
		case BPSC_FILE_END_: // Project File complete
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
		case BPSC_PROJECT_START_: // Project Folder
		{
			NSString *eventName = [stream PopString];
			NSString *sessionName = [stream PopString];
			int sizeInMB = [stream PopInt];
			
			[[BasePadCoordinator Instance] projectDownloadStarting:eventName SessionName:sessionName SizeInMB:sizeInMB];
			
			sizeDownloaded = 0;
			break;
		}

		case BPSC_ACCEPT_PUSH_DATA_: // Accept Push Data
		{
			NSString *session = [stream PopString];
			[[BasePadCoordinator Instance] acceptPushData:session];
			break;
		}
		case BPSC_CANCEL_PROJECT_: // Cancel Project Send
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
			[[BasePadCoordinator Instance] projectDownloadCancelled];
			break;
		}
		case BPSC_COMPLETE_PROJECT_: // Cancel Project Send
		{
			[[BasePadCoordinator Instance] projectDownloadComplete];
			break;
		}

		case BPSC_PROJECT_RANGE_:
		{
			int start = [stream PopInt];
			int end = [stream PopInt];
			[[BasePadCoordinator Instance] setProjectRange:start End:end];
			break;
		}
		case BPSC_HTML_FILE_:
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

		case BPSC_LIVE_TIME_: // Live Time
		{
			float time = [stream PopFloat];
			[[BasePadCoordinator Instance] setLiveTime:time];
			break;
		}
		case BPSC_SPONSOR_: //Sponsor
		{
			NSString *name = [stream PopString];
			[[BasePadSponsor Instance] setSponsorName:name];
			[[BasePadCoordinator Instance] updateSponsor];
			break;
		}
		case BPSC_TIME_SYNC_: // Synchronise Time
		{
			float time = [stream PopFloat];
			[[BasePadCoordinator Instance] synchroniseTime:time];
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
