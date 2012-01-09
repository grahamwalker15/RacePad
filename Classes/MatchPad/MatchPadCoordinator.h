//
//  MatchPadCoordinator.h
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadCoordinator.h"
#import "SettingsViewController.h"
#import "CompositeViewController.h"

@class BasePadViewController;
@class MatchPadClientSocket;
@class MatchPadDataHandler;
@class ElapsedTime;
@class DownloadProgress;
@class ServerConnect;
@class WorkOffline;
@class PlayerStatsController;

// View types
enum ViewTypes
{
	MPC_VIDEO_VIEW_ = BPC_VIDEO_VIEW_,
	MPC_SETTINGS_VIEW_ = BPC_SETTINGS_VIEW_,
	MPC_PITCH_VIEW_ = 0x4,
	MPC_PLAYER_STATS_VIEW_ = 0x8,
	MPC_COMMENTARY_VIEW_ = 0x400,
	MPC_SCORE_VIEW_ = 0x800,
	MPC_PLAYER_GRAPH_VIEW_ = 0x1000,
	MPC_POSSESSION_VIEW_ = 0x2000,
	MPC_MOVE_VIEW_ = 0x4000,
	MPC_BALL_VIEW_ = 0x8000,
} ;

@interface MatchPadCoordinator : BasePadCoordinator
{
	PlayerStatsController *playerStatsController;
}

@property (retain) PlayerStatsController *playerStatsController;

+(MatchPadCoordinator *)Instance;

- (void) clearStaticData;
- (void) requestInitialData;
- (void) requestConnectedData;

- (NSString *)archiveName;
- (NSString *)baseChunkName;
- (void) streamData:(BPCView *)existing_view;
- (void) requestData:(BPCView *)existing_view;
- (void) addDataSource:(int)type Parameter:(NSString *)parameter;

@end
