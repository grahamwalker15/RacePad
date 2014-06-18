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
#import "BasePadCoordinator.h"

@class BasePadViewController;
@class RaceMapClientSocket;
@class RaceMapDataHandler;
@class ElapsedTime;
@class RaceMapServerConnect;
@class RaceMapWorkOffline;

// View types
enum ViewTypes
{
	RPC_VIDEO_VIEW_ = BPC_VIDEO_VIEW_, // 0x1
	RPC_SETTINGS_VIEW_ = BPC_SETTINGS_VIEW_, // 0x2
	RPC_COMMENTARY_VIEW_ = BPC_COMMENTARY_VIEW_, // 0x4
	RPC_DRIVER_LIST_VIEW_ = 0x8,
	RPC_LAP_LIST_VIEW_ = 0x10,
	RPC_TRACK_MAP_VIEW_ = 0x20,
	RPC_LAP_COUNT_VIEW_ = 0x40,
	RPC_TRACK_STATE_VIEW_ = 0x80,
	RPC_TIMING_PAGE_1_ = 0x100,
	RPC_TIMING_PAGE_2_ = 0x200,
};

@interface RaceMapCoordinator : BasePadCoordinator
{

}

+ (RaceMapCoordinator *)Instance;

- (void) clearStaticData;
- (void) requestInitialData;
- (void) requestConnectedData;

- (void) updateDriverNames;

- (NSString *)archiveName;
- (NSString *)baseChunkName;
- (void) streamData:(BPCView *)existing_view;
- (void) requestData:(BPCView *)existing_view;
- (void) addDataSource:(int)type Parameter:(NSString *)parameter;

- (void) notifyNewConnection;

@end
