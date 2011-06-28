//
//  MatchPadCoordinator.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"
#import "MatchPadAppDelegate.h"
#import "MatchPadSponsor.h"
#import "BasePadViewController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadClientSocket.h"
#import "MatchPadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "MatchPadDatabase.h"
#import "CompositeViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "TabletState.h"
#import "PlayerStatsController.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation MatchPadCoordinator

@synthesize playerStatsController;

static MatchPadCoordinator * instance_ = nil;

+(MatchPadCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[MatchPadCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{	
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
}

- (void) requestInitialData
{
	[(MatchPadClientSocket*)socket_ SynchroniseTime];
	[(MatchPadClientSocket*)socket_ RequestEvent];
	[(MatchPadClientSocket*)socket_ RequestTeams];
	[(MatchPadClientSocket*)socket_ RequestUIImages];
}

- (void) requestConnectedData
{
}

- (void) redrawCommentary
{
}

- (void) restartCommentary
{
}

- (NSString *)archiveName
{
	return @"match_pad.mpa";
}

- (NSString *)baseChunkName
{
	return @"match_pad";
}

- (BasePadDataHandler *)allocateDataHandler
{
	return [MatchPadDataHandler alloc];
}

- (int) serverPort
{
	return 6022;
}

- (BasePadClientSocket*) createClientSocket
{
	return [[MatchPadClientSocket alloc] CreateSocket];
}

-(void) streamData:(BPCView *)existing_view
{
	if([existing_view Type] == MPC_PITCH_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamPitch];
	}
	else if([existing_view Type] == MPC_SCORE_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamScore];
	}
	else if([existing_view Type] == MPC_PLAYER_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamPlayerStats];
	}
}

-(void) requestData:(BPCView *)existing_view
{
	if([existing_view Type] == MPC_PITCH_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPitch];
	}
	else if([existing_view Type] == MPC_SCORE_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestScore];
	}
	else if([existing_view Type] == MPC_PLAYER_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPlayerStats];
	}
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	if (type == MPC_PITCH_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"pitch"];
	}
	else if (type == MPC_SCORE_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"score"];
	}
	else if (type == MPC_PLAYER_STATS_VIEW_)
	{
		if ( playerStatsController.home )
			[self AddDataSourceWithType:type AndFile: @"HomePlayerStats"];
		else
			[self AddDataSourceWithType:type AndFile: @"AwayPlayerStats"];
	}
}

@end


