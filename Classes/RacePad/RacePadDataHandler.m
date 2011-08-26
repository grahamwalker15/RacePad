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
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "RacePadTitleBarController.h"
#import "RacePadSponsor.h"
#import "TrackMap.h"

@implementation RacePadDataHandler

- (id) init
{
	[super init];

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
			
		case RPSC_DRIVER_VIEW_: // Driver view
		{
			TableData *driver = [[RacePadDatabase Instance] driverData];
			[driver loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_LAP_LIST_VIEW_];
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
		/*
		case RPSC_RED_COMMENTARY_: // Red Commentary
		{
			CommentaryData *commentary = [[RacePadDatabase Instance] redCommentary];
			[commentary loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_COMMENTARY_VIEW_];
			break;
		}
		case RPSC_BLUE_COMMENTARY_: // Red Commentary
		{
			CommentaryData *commentary = [[RacePadDatabase Instance] blueCommentary];
			[commentary loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_COMMENTARY_VIEW_];
			break;
		}
		*/
		case RPSC_COMMENTARY_: // Commentary
		{
			CommentaryData *commentary = [[RacePadDatabase Instance] commentary];
			[commentary clearAll];
			[commentary loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_COMMENTARY_VIEW_];
			break;
		}
		case RPSC_COMMENTARY_UPDATE_: // Commentary update
		{
			CommentaryData *commentary = [[RacePadDatabase Instance] commentary];
			[commentary loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_COMMENTARY_VIEW_];
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
		case RPSC_BAD_USER_: // New user not accepted
		{
			[[RacePadCoordinator Instance] badUser];
			break;
		}
		case RPSC_LIVE_TIME_: // Live Time
		{
			float time = [stream PopFloat];
			[[RacePadCoordinator Instance] setLiveTime:time];
			break;
		}
		case RPSC_DRIVER_GAP_INFO_: // Driver info plus gaps
		{
			DriverGapInfo *driverGapInfo = [[RacePadDatabase Instance] driverGapInfo];
			[driverGapInfo loadData:stream];
			[[RacePadCoordinator Instance] RequestRedrawType:RPC_DRIVER_GAP_INFO_VIEW_];
			break;
		}
		case RPSC_NOTIFY_NEW_CONNECTION_:
		{
			[[RacePadCoordinator Instance] notifyNewConnection];
			break;
		}
			
		default:
			[super handleCommand:command];
	}
}

@end
