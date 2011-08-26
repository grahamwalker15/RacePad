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

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation RacePadCoordinator

@synthesize gameViewController;

static RacePadCoordinator * instance_ = nil;

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
		gameViewController = nil;
		lightRestart = false;
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
	[self updatePrediction];
}

- (void) requestInitialData
{
	[(RacePadClientSocket*)socket_ SynchroniseTime];
	[(RacePadClientSocket*)socket_ RequestEvent];
	[(RacePadClientSocket*)socket_ RequestTrackMap];
	[(RacePadClientSocket*)socket_ RequestPitWindowBase];
	if ( !lightRestart )
		[(RacePadClientSocket*)socket_ RequestUIImages];
}

- (void) requestConnectedData
{
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

- (int) serverPort
{
	return 6021;
}

- (BasePadClientSocket*) createClientSocket
{
	return [[RacePadClientSocket alloc] CreateSocket];
}

-(void) streamData:(BPCView *)existing_view
{
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RacePadClientSocket*)socket_ StreamTimingPage];
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
			[(RacePadClientSocket*)socket_ requestDriverView:driver];
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
}

-(void) requestData:(BPCView *)existing_view
{
	if([existing_view Type] == RPC_DRIVER_LIST_VIEW_)
	{
		[(RacePadClientSocket*)socket_ RequestTimingPage];
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
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	if (type == RPC_DRIVER_LIST_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"timing"];
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
}

-(void) restartCommentary
{
	int view_count = [views count];
	bool first = true;
	
	for ( int i = 0 ; i < view_count ; i++)
	{
		BPCView * existing_view = [views objectAtIndex:i];
		if([existing_view Displayed])
		{
			int type = [existing_view Type];
			
			if ( type == RPC_COMMENTARY_VIEW_ )
			{
				if ( first )
				{
					NSString *name = [[[RacePadDatabase Instance] commentary] commentaryFor];
					if ( name == nil )
						name = @"RACE";
					
					if (connectionType == BPC_SOCKET_CONNECTION_)
						[socket_ StreamCommentary:name];
					else
						[self loadBPF:[self archiveName] File:@"commentary" SubIndex:name];
					first = false;
				}
				[[existing_view View] RequestRedraw];
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

@end

