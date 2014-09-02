//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapCoordinator.h"

#import "BasePadMedia.h"
#import "RaceMapAppDelegate.h"
#import "RaceMapSponsor.h"
#import "BasePadViewController.h"
#import "RaceMapTitleBarController.h"
#import "RaceMapClientSocket.h"
#import "RaceMapDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "RaceMapData.h"
#import "CompositeViewController.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "TabletState.h"
#import "FileDataStream.h"
#import "MCSocket.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation RaceMapCoordinator

static RaceMapCoordinator * instance_ = nil;

+(RaceMapCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[RaceMapCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		instance_ = self;
		
		lightRestart = false;
        
        mcSocket = nil;
		
		[[BasePadMedia Instance] setExtendedNotification:true];
        
        [self loadLocalTrackMap];
	}
	
	return self;
}

- (void)dealloc
{
    [mcSocket Disconnect];
    [super dealloc];
}

-(void) loadLocalTrackMap
{
    TrackMap *track_map = [[RaceMapData Instance] trackMap];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsFolder = [paths objectAtIndex:0];
    
    NSString *name = @"circuit.map";
    NSString *fileName = [docsFolder stringByAppendingPathComponent:name];

    NSFileManager *fm = [[NSFileManager alloc]init];
    BOOL isDir = false;
    [fm setDelegate:self];
    
    if ( [fm fileExistsAtPath:fileName isDirectory:isDir])
    {
        FileDataStream *stream = [[FileDataStream alloc] initWithPath:fileName];
        [track_map loadTrack:stream Save:false];
        [self RequestRedrawType:RPC_TRACK_MAP_VIEW_];
        [stream release];
   }

    name = @"distance.map";
    fileName = [docsFolder stringByAppendingPathComponent:name];
    if ( [fm fileExistsAtPath:fileName isDirectory:isDir])
    {
        FileDataStream *stream = [[FileDataStream alloc] initWithPath:fileName];
        [track_map loadDistanceMap:stream Save:false];
        [stream release];
    }
   
    name = @"tla.map";
    fileName = [docsFolder stringByAppendingPathComponent:name];
    if ( [fm fileExistsAtPath:fileName isDirectory:isDir])
    {
        FileDataStream *stream = [[FileDataStream alloc] initWithPath:fileName];
        [track_map loadTLAMap:stream Save:false];
        [stream release];
    }
    
   [fm release];

}

-(void) clearStaticData
{
	[super clearStaticData];
}

- (void) requestInitialData
{
	[(RaceMapClientSocket*)socket_ SynchroniseTime];
	[(RaceMapClientSocket*)socket_ RequestEvent];
	[(RaceMapClientSocket*)socket_ RequestTrackMap];
	[(RaceMapClientSocket*)socket_ RequestDistanceMap];
	[(RaceMapClientSocket*)socket_ RequestTLAMap];
	[(RaceMapClientSocket*)socket_ RequestPitWindowBase];
	if ( !lightRestart )
		[(RaceMapClientSocket*)socket_ RequestUIImages];
}

- (void) requestConnectedData
{
}

- (void) notifyNewConnection
{
	[self clearStaticData];
	[self requestInitialData];
}

-(void) updateDriverNames
{
}

- (NSString *)archiveName
{
	return @"race_pad.rpa";
}

- (NSString *)baseChunkName
{
	return @"race_pad";
}

- (BasePadDataHandler *)allocateDataHandler
{
	return [RacePadDataHandler alloc];
}

- (int) serverPort
{
	return 6021;
}

- (BasePadClientSocket*) createClientSocket
{
	return [[RaceMapClientSocket alloc] CreateSocket];
}

- (void) goOffline
{
}

-(void) streamData:(BPCView *)existing_view
{
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RaceMapClientSocket*)socket_ StreamTimingPage];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_1_)
	{
		[(RaceMapClientSocket*)socket_ StreamTimingPage1];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_2_)
	{
		[(RaceMapClientSocket*)socket_ StreamTimingPage2];
	}
	else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
	{
		NSString * driver = [existing_view Parameter];
		if([driver length] > 0)
		{
			[(RaceMapClientSocket*)socket_ StreamDriverView:driver];
		}
	}
	else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
	{
		[(RaceMapClientSocket*)socket_ StreamCars];
	}
}

-(void) requestData:(BPCView *)existing_view
{
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RaceMapClientSocket*)socket_ RequestTimingPage];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_1_)
	{
		[(RaceMapClientSocket*)socket_ RequestTimingPage1];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_2_)
	{
		[(RaceMapClientSocket*)socket_ RequestTimingPage2];
	}
	else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
	{
		NSString * driver = [existing_view Parameter];
		if([driver length] > 0)
		{
			[(RaceMapClientSocket*)socket_ requestDriverView:driver];
		}
	}
	else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
	{
		[(RaceMapClientSocket*)socket_ RequestCars];
	}
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	if (type == RPC_DRIVER_LIST_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"timing"];
	}
	else if (type == RPC_TIMING_PAGE_1_)
	{
		[self AddDataSourceWithType:type AndFile: @"TimingPage1"];
	}
	else if (type == RPC_TIMING_PAGE_2_)
	{
		[self AddDataSourceWithType:type AndFile: @"TimingPage2"];
	}
	else if (type == RPC_LAP_LIST_VIEW_ )
	{
		[self AddDataSourceWithType:type AndArchive:@"race_pad.rpa" AndFile: @"driver" AndSubIndex:parameter];
	}
	else if (type == RPC_TRACK_MAP_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"cars"];
	}
	else if (type == RPC_LAP_COUNT_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"lap_count"];
	}
}

// MC Socket

-(bool) mcServerConnected
{
	return mcSocket != nil;
}

- (void) mcDisconnect
{
	[mcSocket Disconnect];
	mcSocket = nil;
}

- (void) connectMCServer
{
    NSString *server = [[BasePadPrefs Instance] getPref:@"preferredMCServerAddress"];
	if ( server && [server length] )
	{
		[mcSocket Disconnect];
		mcSocket = [[MCSocket alloc] CreateSocket];
		
		[mcSocket ConnectSocket:[server UTF8String] Port:12009];
		[[BasePadPrefs Instance] setPref:@"preferredMCServerAddress" Value:server];
		[[BasePadPrefs Instance] save];
	}
}

- (void) MCConnected
{
	//Version is automatically sent on connection now...
	//[socket_ RequestVersion];
    [self goLive:true];
}

- (void) MCDisconnected: (bool) atConnect
{
	// If failed at connect (because WiFi is switched off say), then the connect window will already be up
	// So, let timer do it do it's thing
	if ( !atConnect)
	{
		[mcSocket Disconnect];
		mcSocket = nil;
		
		// [self SetMCServerAddress:[[BasePadPrefs Instance] getPref:@"preferredMCServerAddress"]];
		[settingsViewController updateServerState];
	}
    
    /*
    int delegate_count = [connectionFeedbackDelegates count];
    if(delegate_count > 0)
    {
        for ( int i = 0 ; i < delegate_count ; i++)
        {
            id <ConnectionFeedbackDelegate> delegate = [connectionFeedbackDelegates objectAtIndex:i];
            [delegate notifyConnectionFailed];
        }
    }
    */
    [self goLive:false];
}

@end
