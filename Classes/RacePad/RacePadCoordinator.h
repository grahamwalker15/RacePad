//
//  RacePadCoordinator.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"
#import "CompositeViewController.h"
#import "GameViewController.h"
#import "HelpViewController.h"
#import "BasePadCoordinator.h"

@class BasePadViewController;
@class RacePadClientSocket;
@class RacePadDataHandler;
@class ElapsedTime;
@class DownloadProgress;
@class ServerConnect;
@class WorkOffline;

// View types
enum ViewTypes
{
	RPC_VIDEO_VIEW_ = BPC_VIDEO_VIEW_, // 0x1
	RPC_SETTINGS_VIEW_ = BPC_SETTINGS_VIEW_, // 0x3
	RPC_COMMENTARY_VIEW_ = 0x4,
	RPC_DRIVER_LIST_VIEW_ = 0x8,
	RPC_LAP_LIST_VIEW_ = 0x10,
	RPC_TRACK_MAP_VIEW_ = 0x20,
	RPC_LAP_COUNT_VIEW_ = 0x40,
	RPC_PIT_WINDOW_VIEW_ = 0x80,
	RPC_TELEMETRY_VIEW_ = 0x100,
	RPC_LEADER_BOARD_VIEW_ = 0x200,
	RPC_GAME_VIEW_ = 0x400,
	RPC_DRIVER_GAP_INFO_VIEW_ = 0x800
};

@interface RacePadCoordinator : BasePadCoordinator
{
	GameViewController *gameViewController;
}

@property (retain) GameViewController *gameViewController;

+ (RacePadCoordinator *)Instance;

- (void) clearStaticData;
- (void) requestInitialData;
- (void) requestConnectedData;

- (void) updateDriverNames;
- (void) updatePrediction;

- (NSString *)archiveName;
- (NSString *)baseChunkName;
- (void) streamData:(BPCView *)existing_view;
- (void) requestData:(BPCView *)existing_view;
- (void) addDataSource:(int)type Parameter:(NSString *)parameter;

- (void) sendPrediction;
- (void) checkUserName: (NSString *)name;
- (void) requestPrediction: (NSString *)name;
- (void) registeredUser;
- (void) badUser;

- (void) notifyNewConnection;

@end
