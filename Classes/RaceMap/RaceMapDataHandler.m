//
//  RacePadDataHandler.m
//  RacePad
//
//  Created by Mark Riches
//  October 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapDataHandler.h"
#import "DataStream.h"
#import "RaceMapCoordinator.h"
#import "RaceMapData.h"
#import "RaceMapTitleBarController.h"
#import "RaceMapSponsor.h"
#import "TrackMap.h"

@implementation RacePadDataHandler

- (id) init
{
	self = [super init];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (bool) okVersion
{
	return versionNumber <= RACE_PAD_INTERFACE_VERSION;
}

- (void)handleCommand:(int) command
{
	switch (command)
	{
		case RPSC_EVENT_:
		{
			RaceMapData *database = [RaceMapData Instance];
			NSString *string = [stream PopString];
			[ database setEventName:string];
			[[RaceMapTitleBarController Instance] setEventName:string];
			break;
		}
		case RPSC_SESSION_:
		{
			RaceMapData *database = [RaceMapData Instance];
			int session = [stream PopInt];
			[database setSession:session];
			[[RaceMapCoordinator Instance] updateTabs];
			break;
		}
		case RPSC_TRACK_MAP_: // Track Map
		{
			TrackMap *track_map = [[RaceMapData Instance] trackMap];
			[track_map loadTrack:stream Save:true];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
		case RPSC_DISTANCE_MAP_: // Track Map
		{
			TrackMap *track_map = [[RaceMapData Instance] trackMap];
			[track_map loadDistanceMap:stream Save:true];
			break;
		}
		case RPSC_TLA_MAP_: // Track Map
		{
			TrackMap *track_map = [[RaceMapData Instance] trackMap];
			[track_map loadTLAMap:stream Save:true];
			break;
		}
		case RPSC_WHOLE_TIMING_PAGE_: // Timing Page 1 (whole page)
		{
			
			TableData *driver_list = [[RaceMapData Instance] driverListData];
			[driver_list loadData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
		case RPSC_UPDATE_TIMING_PAGE_: // Timing Page 1 (updates)
		{
			TableData *driver_list = [[RaceMapData Instance] driverListData];
			[driver_list updateData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_DRIVER_LIST_VIEW_];
			break;
		}
		case RPSC_WHOLE_TIMING_PAGE_1_: // FOM Timing Page 1 (whole page)
		{
			
			TableData *timing_page = [[RaceMapData Instance] timingPage1];
			[timing_page loadData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TIMING_PAGE_1_];
			break;
		}
		case RPSC_UPDATE_TIMING_PAGE_1_: // FOM Timing Page 1 (updates)
		{
			TableData *timing_page = [[RaceMapData Instance] timingPage1];
			[timing_page updateData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TIMING_PAGE_1_];
			break;
		}
		case RPSC_WHOLE_TIMING_PAGE_2_: // FOM Timing Page 2 (whole page)
		{
			
			TableData *timing_page = [[RaceMapData Instance] timingPage2];
			[timing_page loadData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TIMING_PAGE_2_];
			break;
		}
		case RPSC_UPDATE_TIMING_PAGE_2_: // FOM Timing Page 2 (updates)
		{
			TableData *timing_page = [[RaceMapData Instance] timingPage2];
			[timing_page updateData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TIMING_PAGE_2_];
			break;
		}	
		case RPSC_CARS_: // Track Map Cars
		{
			TrackMap *track_map = [[RaceMapData Instance] trackMap];
			[track_map updateCars:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TRACK_MAP_VIEW_];
			break;
		}
			
		case RPSC_DRIVER_VIEW_: // Driver view (whole page)
		{
			TableData *driver = [[RaceMapData Instance] driverData];
			[driver loadData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_LAP_LIST_VIEW_];
			break;
		}
		case RPSC_UPDATE_DRIVER_VIEW_: // Driver view (Updates)
		{
			TableData *driver = [[RaceMapData Instance] driverData];
			[driver updateData:stream];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_LAP_LIST_VIEW_];
			break;
		}
            
		case RPSC_LAP_COUNT_:
		{
			int count = [stream PopInt];
			[[RaceMapTitleBarController Instance] setLapCount:count];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_LAP_COUNT_VIEW_];
			break;
		}
		case RPSC_LAP_COUNTER_:
		{
			int lap = [stream PopInt];
			[[RaceMapTitleBarController Instance] setCurrentLap:lap];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_LAP_COUNT_VIEW_];
			break;
		}
		case RPSC_TRACK_STATE_:
		{
			int state = [stream PopInt];
			[[RaceMapTitleBarController Instance] setTrackState:state];
			[[RaceMapCoordinator Instance] RequestRedrawType:RPC_TRACK_STATE_VIEW_];
			break;
		}
		case RPSC_DRIVER_NAMES_: // Driver Names
		{
			DriverNames *driverNames = [[RaceMapData Instance] driverNames];
			[driverNames loadData:stream];
			[[RaceMapCoordinator Instance] updateDriverNames];
			break;
		}
		case RPSC_ALERTS_: // Alerts
		{
			RaceMapAlertData *alertData = [[RaceMapData Instance] alertData];
			[alertData loadData:stream];
			break;
		}
		case RPSC_LIVE_TIME_: // Live Time
		{
			float time = [stream PopFloat];
			[[RaceMapCoordinator Instance] setLiveTime:time];
			break;
		}
		case RPSC_NOTIFY_NEW_CONNECTION_:
		{
			[[RaceMapCoordinator Instance] notifyNewConnection];
			break;
		}
			
		default:
			[super handleCommand:command];
	}
}

@end
