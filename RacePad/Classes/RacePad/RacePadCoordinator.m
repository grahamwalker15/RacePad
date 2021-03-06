//
//  RacePadCoordinator.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadCoordinator.h"

#import "BasePadMedia.h"
#import "RacePadAppDelegate.h"
#import "RacePadSponsor.h"
#import "BasePadViewController.h"
#import "RacePadTitleBarController.h"
#import "RacePadClientSocket.h"
#import "RacePadEMMSocket.h"
#import "RacePadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "RacePadDatabase.h"
#import "CompositeViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "TabletState.h"
#import "CommentaryView.h"
#import	"CommentaryBubble.h"
#import "AccidentView.h"
#import	"AccidentBubble.h"
#import	"MidasVoting.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation RacePadCoordinator

static RacePadCoordinator * instance_ = nil;

@synthesize gameViewController;
@synthesize dataServerType;

+(RacePadCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[RacePadCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{
		instance_ = self;
		
		gameViewController = nil;
		lightRestart = false;
		
		dataServerType = RPC_NORMAL_SERVER_;
		NSString * serverType = [[[BasePadPrefs Instance] getPref:@"dataServerType"] retain];
		
		if(serverType && [serverType isEqualToString:@"TRACK"])
			dataServerType = RPC_TRACK_SERVER_;
		
		[serverType release];
		
		[[BasePadMedia Instance] setExtendedNotification:true];
	}
	
	return self;
}

- (void)dealloc
{
	[gameViewController release];
    [super dealloc];
}

-(void) clearStaticData
{
	[super clearStaticData];
	[[RacePadTitleBarController Instance] setLapCount:0]; // To put it back into time mode
	[self updatePrediction];
}

- (void) requestInitialData
{
	if(dataServerType == RPC_TRACK_SERVER_)
	{
		TrackMap *track_map = [[RacePadDatabase Instance] trackMap];
		[track_map loadTrackFromTemporaryFile];
		return;
	}
	
	[(RacePadClientSocket*)socket_ SynchroniseTime];
	[(RacePadClientSocket*)socket_ RequestEvent];
	[(RacePadClientSocket*)socket_ RequestTrackMap];
	[(RacePadClientSocket*)socket_ RequestPitWindowBase];
	if ( !lightRestart )
		[(RacePadClientSocket*)socket_ RequestUIImages];
}

- (void) onSuccessfulConnection
{
	if(dataServerType == RPC_TRACK_SERVER_)
	{
		[self selectTab:3];
	}
}

- (void) requestConnectedData
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return;
	
	[self requestPrediction:[[[RacePadDatabase Instance] racePrediction] user]];
}

- (void) notifyNewConnection
{
	[self clearStaticData];
	[self requestInitialData];
}

-(void) updateDriverNames
{
}

- (void) updatePrediction
{
	if ( gameViewController )
		[gameViewController updatePrediction];
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

- (NSString *) PreferredServerAddress
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return [[BasePadPrefs Instance] getPref:@"preferredTrackServerAddress"];
	else
		return [[BasePadPrefs Instance] getPref:@"preferredServerAddress"];
}


- (void) UpdateServerPrefs : (NSString *) server
{
	if(dataServerType == RPC_TRACK_SERVER_)
		[[BasePadPrefs Instance] setPref:@"preferredTrackServerAddress" Value:server];
	else
		[[BasePadPrefs Instance] setPref:@"preferredServerAddress" Value:server];

	[[BasePadPrefs Instance] save];
}

- (int) serverPort
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return 2001;
	else
		return 6021;
}

- (BasePadClientSocket*) createClientSocket
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return [[RacePadEMMSocket alloc] CreateSocket];
	else
		return [[RacePadClientSocket alloc] CreateSocket];
}

-(void) streamData:(BPCView *)existing_view
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return;
	
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamTimingPage];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_1_)
	{
		[(RacePadClientSocket*)socket_ StreamTimingPage1];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_2_)
	{
		[(RacePadClientSocket*)socket_ StreamTimingPage2];
	}
	else if([existing_view Type] == RPC_MIDAS_STANDINGS_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamStandingsView];
	}
	else if([existing_view Type] == RPC_DRIVER_VOTING_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamDriverVoting];
	}
	else if([existing_view Type] == RPC_LEADER_BOARD_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamLeaderBoard];
	}
	else if([existing_view Type] == RPC_GAME_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamGameView];
	}
	else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
	{
		NSString * driver = [existing_view Parameter];
		if([driver length] > 0)
		{
			[(RacePadClientSocket*)socket_ StreamDriverView:driver];
		}
	}
	else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamCars];
	}
	else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamPitWindow];
	}
	else if([existing_view Type] == RPC_TELEMETRY_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamTelemetry];
	}
	else if([existing_view Type] == RPC_DRIVER_GAP_INFO_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamDriverGapInfo:[[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
	}
	else if([existing_view Type] == RPC_HEAD_TO_HEAD_VIEW_)
	{
		HeadToHead *h2h = [[RacePadDatabase Instance] headToHead];
		[(RacePadClientSocket*)socket_ StreamHeadToHead:[h2h driver0] Driver1:[h2h driver1]];
	}
}

-(void) requestData:(BPCView *)existing_view
{
	if(dataServerType == RPC_TRACK_SERVER_)
		return;
	
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestTimingPage];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_1_)
	{
		[(RacePadClientSocket*)socket_ RequestTimingPage1];
	}
	else if([existing_view Type] == RPC_TIMING_PAGE_2_)
	{
		[(RacePadClientSocket*)socket_ RequestTimingPage2];
	}
	else if([existing_view Type] == RPC_MIDAS_STANDINGS_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestStandingsView];
	}
	else if([existing_view Type] == RPC_DRIVER_VOTING_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestDriverVoting];
	}
	else if([existing_view Type] == RPC_LEADER_BOARD_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestLeaderBoard];
	}
	else if([existing_view Type] == RPC_GAME_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestGameView];
	}
	else if([existing_view Type] == RPC_LAP_LIST_VIEW_)
	{
		NSString * driver = [existing_view Parameter];
		if([driver length] > 0)
		{
			[(RacePadClientSocket*)socket_ requestDriverView:driver];
		}
	}
	else if([existing_view Type] == RPC_TRACK_MAP_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestCars];
	}
	else if([existing_view Type] == RPC_PIT_WINDOW_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestPitWindow];
	}
	else if([existing_view Type] == RPC_TELEMETRY_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestTelemetry];
	}
	else if([existing_view Type] == RPC_DRIVER_GAP_INFO_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestDriverGapInfo:[[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
	}
	else if([existing_view Type] == RPC_HEAD_TO_HEAD_VIEW_)
	{
		HeadToHead *h2h = [[RacePadDatabase Instance] headToHead];
		[(RacePadClientSocket*)socket_ RequestHeadToHead:[h2h driver0] Driver1:[h2h driver1]];
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
	else if (type == RPC_MIDAS_STANDINGS_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"standings"];
	}
	else if (type == RPC_DRIVER_VOTING_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"voting"];
	}
	else if (type == RPC_LEADER_BOARD_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"leader"];
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
	else if (type == RPC_PIT_WINDOW_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"pit_window"];
	}
	else if (type == RPC_TELEMETRY_VIEW_ )
	{
		[self AddDataSourceWithType:type AndFile: @"telemetry"];
	}
	else if (type == RPC_GAME_VIEW_ )
	{
		[self AddDataSourceWithType:type AndArchive:@"game.rpa" AndFile: @"game" AndSubIndex: nil];
	}
	else if (type == RPC_DRIVER_GAP_INFO_VIEW_ )
	{
		[self AddDataSourceWithType:type AndArchive:@"race_pad.rpa" AndFile: @"driver_gap" AndSubIndex: [[[RacePadDatabase Instance] driverGapInfo] requestedDriver]];
	}
	else if(type == RPC_HEAD_TO_HEAD_VIEW_)
	{
		HeadToHead *h2h = [[RacePadDatabase Instance] headToHead];
		NSString *driver0 = h2h.driver0;
		NSString *driver1 = h2h.driver1;
		if ( !driver0 )
			driver0 = @"";
		if ( !driver1 )
			driver1 = @"";
		NSString *subIndex = [NSString stringWithFormat:@"%s_%s",[driver0 UTF8String],[driver1 UTF8String]];
		[self AddDataSourceWithType:type AndArchive:@"race_pad.rpa" AndFile: @"head_to_head" AndSubIndex: subIndex];
	}
}

- (void) resetCommentaryTimings
{
	[[CommentaryBubble Instance] resetBubbleTimings];
}

-(void) redrawAccidents
{
	bool matched = false;
	// if(registeredViewController && (registeredViewControllerTypeMask & RPC_COMMENTARY_VIEW_) > 0)
	{
		int view_count = [views count];
		
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				int type = [existing_view Type];
				
				if ( type == RPC_ACCIDENT_VIEW_ )
				{
					AccidentView *accidents = [existing_view View];
					if ( accidents )
					{
						[accidents drawIfChanged];
						matched = true;
					}
				}
			}
		}
	}
	
	if ( matched )
	{
		[[AccidentBubble Instance] showIfNeeded];
	}
}

-(void) redrawCommentary
{
	bool matched = false;
	// if(registeredViewController && (registeredViewControllerTypeMask & RPC_COMMENTARY_VIEW_) > 0)
	{
		int view_count = [views count];
		
		for ( int i = 0 ; i < view_count ; i++)
		{
			BPCView * existing_view = [views objectAtIndex:i];
			if([existing_view Displayed])
			{
				int type = [existing_view Type];
				
				if ( type == RPC_COMMENTARY_VIEW_ )
				{
					CommentaryView *commentary = [existing_view View];
					if ( commentary )
					{
						[commentary drawIfChanged];
						matched = true;
					}
				}
			}
		}
	}
	
	if ( matched )
	{
		[[CommentaryBubble Instance] showIfNeeded];
	}
	
	[self redrawAccidents];
}

-(void) restartCommentary
{
	int view_count = [views count];
	
	for ( int i = 0 ; i < view_count ; i++)
	{
		BPCView * existing_view = [views objectAtIndex:i];
		if([existing_view Displayed])
		{
			int type = [existing_view Type];
			
			if ( type == RPC_COMMENTARY_VIEW_ )
			{
				NSString *name = [[[RacePadDatabase Instance] commentary] commentaryFor];
				if ( name == nil )
					name = @"RACE";
				
				if (connectionType == BPC_SOCKET_CONNECTION_)
					[socket_ StreamCommentary:name];
				else
					[self loadBPF:[self archiveName] File:@"commentary" SubIndex:name];
				break;
			}
		}
	}
}

-(void) sendPrediction
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[(RacePadClientSocket *)socket_ sendPrediction];
}

-(void) checkUserName: (NSString *)name
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[(RacePadClientSocket *)socket_ checkUserName:name];
	else
	{
		[gameViewController cancelledRegister];
	}
}

-(void) requestPrediction: (NSString *)name
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[(RacePadClientSocket *)socket_ requestPrediction:name];
	else
	{
		[self loadBPF:@"race_pad.rpa" File:@"player" SubIndex:name];
	}
	
}

-(void) registeredUser
{
	[gameViewController registeredUser];
}

-(void) badUser
{
	[gameViewController badUser];
}

- (void) driverThumbsUp:(NSString *) driver
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[(RacePadClientSocket *)socket_ DriverThumbsUp:driver];
	else
		[MidasVoting localThumbsUp];
}

- (void) driverThumbsDown:(NSString *) driver
{
	if (connectionType == BPC_SOCKET_CONNECTION_)
		[(RacePadClientSocket *)socket_ DriverThumbsDown:driver];
	else
		[MidasVoting localThumbsDown];
}


@end
