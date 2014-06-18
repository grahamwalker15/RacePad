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
		
		[[BasePadMedia Instance] setExtendedNotification:true];
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) clearStaticData
{
	[super clearStaticData];
	[[RaceMapTitleBarController Instance] setLapCount:0]; // To put it back into time mode
}

- (void) requestInitialData
{
	[(RaceMapClientSocket*)socket_ SynchroniseTime];
	[(RaceMapClientSocket*)socket_ RequestEvent];
	[(RaceMapClientSocket*)socket_ RequestTrackMap];
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


@end
