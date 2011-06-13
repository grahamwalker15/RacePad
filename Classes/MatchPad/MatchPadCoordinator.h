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

// View types
enum ViewTypes
{
	MPC_PITCH_VIEW_ = 0x4,
	MPC_VIDEO_VIEW_ = 0x8,
	MPC_SETTINGS_VIEW_ = 0x10,
	MPC_COMMENTARY_VIEW_ = 0x400,
} ;

@interface MatchPadCoordinator : BasePadCoordinator
{
}

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
