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
#import "PhysicalStatsController.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation MatchPadCoordinator

@synthesize playerStatsController;
@synthesize physicalStatsController;

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
	else if([existing_view Type] == MPC_POSITIONS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamPositions];
	}
	else if([existing_view Type] == MPC_SCORE_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamScore];
	}
	else if([existing_view Type] == MPC_PLAYER_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamPlayerStats];
	}
	else if([existing_view Type] == MPC_TEAM_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamTeamStats];
	}
	else if([existing_view Type] == MPC_PLAYER_GRAPH_VIEW_)
	{
		PlayerGraph *graph = [[MatchPadDatabase Instance]playerGraph];
		[(MatchPadClientSocket *)socket_ StreamPlayerGraph:[graph requestedPlayer] GraphType:[graph graphType]];
	}
	else if([existing_view Type] == MPC_POSSESSION_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ StreamPossession];
	}
	else if([existing_view Type] == MPC_MOVE_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ StreamMoves];
	}
	else if([existing_view Type] == MPC_BALL_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ StreamBall];
	}
}

-(void) requestData:(BPCView *)existing_view
{
	if([existing_view Type] == MPC_PITCH_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPitch];
	}
	else if([existing_view Type] == MPC_POSITIONS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPositions];
	}
	else if([existing_view Type] == MPC_SCORE_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestScore];
	}
	else if([existing_view Type] == MPC_PLAYER_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPlayerStats];
	}
	else if([existing_view Type] == MPC_PHYSICAL_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPhysicalStats];
	}
	else if([existing_view Type] == MPC_TEAM_STATS_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestTeamStats];
	}
	else if([existing_view Type] == MPC_PLAYER_GRAPH_VIEW_)
	{
		PlayerGraph *graph = [[MatchPadDatabase Instance]playerGraph];
		[(MatchPadClientSocket *)socket_ RequestPlayerGraph:[graph requestedPlayer] GraphType:[graph graphType]];
	}
	else if([existing_view Type] == MPC_POSSESSION_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ RequestPossession];
	}
	else if([existing_view Type] == MPC_CODING_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ RequestCoding];
	}
	else if([existing_view Type] == MPC_MOVE_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ RequestMoves];
	}
	else if([existing_view Type] == MPC_BALL_VIEW_)
	{
		[(MatchPadClientSocket*)socket_ RequestBall];
	}
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	if (type == MPC_PITCH_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"pitch"];
	}
	else if (type == MPC_POSITIONS_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"positions"];
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
	else if (type == MPC_TEAM_STATS_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"TeamStats"];
	}
	else if (type == MPC_PLAYER_GRAPH_VIEW_)
	{
		NSString *name = @"PlayerGraph-";
		NSNumber *graphType = [NSNumber numberWithInt:[[[MatchPadDatabase Instance]playerGraph]graphType]];
		NSNumber *number = [NSNumber numberWithInt:[[[MatchPadDatabase Instance]playerGraph]requestedPlayer]];
		name = [name stringByAppendingString:[graphType stringValue]];
		name = [name stringByAppendingString:@"-"];
		name = [name stringByAppendingString:[number stringValue]];
		[self AddDataSourceWithType:type AndFile: name];
	}
	else if (type == MPC_POSSESSION_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"Possession"];
	}
	else if (type == MPC_MOVE_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"Moves"];
	}
	else if (type == MPC_BALL_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"Ball"];
	}
	else if (type == MPC_PHYSICAL_STATS_VIEW_)
	{
		if ( physicalStatsController.home )
			[self AddDataSourceWithType:type AndFile: @"HomePhysicalStats"];
		else
			[self AddDataSourceWithType:type AndFile: @"AwayPhysicalStats"];
	}
	else if (type == MPC_CODING_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"Coding"];
	}
    
}

///////////////////////////////////////
// Overrides for connection callbacks

- (void) loadSession: (NSString *)event Session: (NSString *)session
{
	[self goLive:false];
	
	[self disconnect];
	[self clearStaticData];
	sessionPrefix = [NSString stringWithString:event];
	sessionPrefix = [sessionPrefix stringByAppendingString:@"-"];
	sessionPrefix = [sessionPrefix stringByAppendingString:session];
	sessionPrefix = [sessionPrefix stringByAppendingString:@"-"];
	[sessionPrefix retain];
	NSString *archive = [self archiveName];
	[self loadBPF: archive File:[self baseChunkName] SubIndex:nil];
	[self loadBPF: archive File:@"event" SubIndex:nil];
	[self loadBPF: archive File:@"session" SubIndex:nil];
	[self loadBPF: archive File:@"Coding" SubIndex:nil];
	
	[[BasePadPrefs Instance] setPref:@"preferredEvent" Value:event ];
	[[BasePadPrefs Instance] setPref:@"preferredSession" Value:session];
	
	[self setConnectionType:BPC_ARCHIVE_CONNECTION_];
	
	[[BasePadMedia Instance] verifyAudioLoaded];
	
	[self onSessionLoaded];
}

-(void)onSessionLoaded
{
	[[BasePadMedia Instance] verifyMovieLoaded];
	[self prepareToPlay];
	[self startPlay];
}

- (void) onSuccessfulConnection
{
	[[BasePadMedia Instance] verifyMovieLoaded];
}

@end


