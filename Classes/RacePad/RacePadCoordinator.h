//
//  RacePadCoordinator.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"
#import "GameViewController.h"


@class RacePadViewController;
@class RacePadClientSocket;
@class RacePadDataHandler;
@class ElapsedTime;
@class DownloadProgress;
@class ServerConnect;
@class WorkOffline;

// View types
enum ViewTypes
{
	RPC_DRIVER_LIST_VIEW_ = 0x1,
	RPC_LAP_LIST_VIEW_ = 0x2,
	RPC_TRACK_MAP_VIEW_ = 0x4,
	RPC_VIDEO_VIEW_ = 0x8,
	RPC_SETTINGS_VIEW_ = 0x10,
	RPC_LAP_COUNT_VIEW_ = 0x20,
	RPC_PIT_WINDOW_VIEW_ = 0x40,
	RPC_TELEMETRY_VIEW_ = 0x80,
	RPC_LEADER_BOARD_VIEW_ = 0x100,
	RPC_GAME_VIEW_ = 0x200,
	RPC_COMMENTARY_VIEW_ = 0x400,
	RPC_DRIVER_GAP_INFO_VIEW_ = 0x800,
	RPC_TRACK_PROFILE_VIEW_ = 0x1000,
} ;

// Connection types
enum ConnectionTypes
{
	RPC_NO_CONNECTION_,
	RPC_SOCKET_CONNECTION_,
	RPC_ARCHIVE_CONNECTION_,
	
	RPC_VIDEO_LIVE_CONNECTION_,
	RPC_VIDEO_ARCHIVE_CONNECTION_,
	
	RPC_CONNECTION_CONNECTING_,
	RPC_CONNECTION_SUCCEEDED_,
	RPC_CONNECTION_FAILED_,
} ;

@interface RPCView : NSObject
{
	id view_;
	int type_;
	NSString * parameter_;
	bool displayed_;
	bool refresh_enabled_;
}

@property (nonatomic, retain, setter=SetView, getter=View) id view_;
@property (nonatomic, retain, setter=SetParameter, getter=Parameter) NSString * parameter_;
@property (nonatomic, setter=SetType, getter=Type) int type_;
@property (nonatomic, setter=SetDisplayed, getter=Displayed) bool displayed_;
@property (nonatomic, setter=SetRefreshEnabled, getter=RefreshEnabled) bool refresh_enabled_;

-(id)initWithView:(id)view AndType:(int)type;

@end

@interface RPCDataSource : NSObject
{
	RacePadDataHandler * dataHandler;
	NSString * fileName;
	int archiveType;
	int referenceCount;
}

@property (nonatomic, retain) RacePadDataHandler * dataHandler;;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic) int archiveType;
@property (nonatomic, readonly) int referenceCount;

-(id)initWithDataHandler:(RacePadDataHandler *)handler Type:(int)type Filename:(NSString *)name;

-(void)incrementReferenceCount;
-(void)decrementReferenceCount;

@end


@interface RacePadCoordinator : NSObject
{
	int connectionType;
	
	NSMutableArray * views;		// RPCView *
	NSMutableArray * dataSources;	// RPCDataSource *
	
	RacePadViewController * registeredViewController;
	int registeredViewControllerTypeMask;
	
	DownloadProgress *downloadProgress;
	ServerConnect *serverConnect;
	WorkOffline *workOffline;
	SettingsViewController *settingsViewController;
	GameViewController *gameViewController;
	
	bool firstView;
	
	RacePadClientSocket * socket_;
	int connectionRetryCount;
	bool showingConnecting;
	
	int serverConnectionStatus;

	int videoConnectionType;
	int videoConnectionStatus;
	
	NSString *sessionPrefix;
	
	NSTimer *updateTimer;
	NSTimer *timeControllerTimer;
	NSTimer *connectionRetryTimer;
	
	int baseTime;
	ElapsedTime * elapsedTime;
	
	bool live;
	float currentTime;
	float startTime;
	float endTime;
	
	float playbackRate;
	float activePlaybackRate;
	
	float serverTimeOffset;
	
	bool playing;
	bool needsPlayRestart;
	
	bool reconnectOnBecomeActive;
	bool playOnBecomeActive;
	bool jumpOnBecomeActive;
	float restartTime;
	
	bool liveMovieSeekAllowed;
	
	NSMutableArray *allTabs;
	unsigned char currentSponsor;
}

@property (nonatomic) int connectionType;
@property (nonatomic) float currentTime;
@property (nonatomic) float startTime;
@property (nonatomic) float endTime;
@property (nonatomic) float playbackRate;
@property (nonatomic) bool playing;
@property (nonatomic) bool needsPlayRestart;

@property (nonatomic) int serverConnectionStatus;

@property (nonatomic) int videoConnectionType;
@property (nonatomic) int videoConnectionStatus;

@property (nonatomic) bool liveMovieSeekAllowed;

@property (readonly) float serverTimeOffset;

@property (readonly) RacePadViewController * registeredViewController;
@property (retain) SettingsViewController *settingsViewController;
@property (retain) GameViewController *gameViewController;

+(RacePadCoordinator *)Instance;

-(void)onStartUp;

-(int) deviceOrientation;

-(void)startPlay;
-(void)pausePlay;
-(void)stopPlay;

-(void)prepareToPlay;
-(void)showSnapshot;

-(void)userPause;
-(void)jumpToTime:(float)time;

-(bool)playingRealTime;

-(void)setServerConnected:(bool)ok;
-(bool)serverConnected;
-(void)SetServerAddress:(NSString *)server ShowWindow:(BOOL)showWindow;
-(void) disconnect;
-(void)Connected;
-(void)Disconnected:(bool) atConnect;
-(void) connectionTimeout;

- (void) videoServerOnConnectionChange;

-(void)SetVideoServerAddress:(NSString *)server;

-(void) goOffline;
-(void) goLive: (bool)newMode;
-(bool) liveMode;
-(void) setLiveTime:(float)time;
-(float) liveTime;
-(float) playTime;

-(void) userExit;
-(void) userRestart;

-(void) setProjectRange:(int)start End:(int)end;

-(void) prepareToPlayFromSocket;
-(void) showSnapshotFromSocket;

-(void) acceptPushData:(NSString *)session;
-(void) projectDownloadStarting:(NSString *)event SessionName:(NSString *)session SizeInMB:(int) sizeInMB;
-(void) projectDownloadCancelled;
-(void)	projectDownloadComplete;
-(void) projectDownloadProgress:(int) sizeInMB;
-(void) cancelDownload;

-(void)loadRPF:(NSString *)file SubIndex:(NSString *)subIndex;
-(void)loadSession:(NSString *)event Session: (NSString *)session;
-(NSString *)getVideoArchiveName;

-(void) prepareToPlayArchives;
-(void) showSnapshotOfArchives;

-(void)setTimer: (float)thisTime;
-(void)timerUpdate: (NSTimer *)theTimer;

-(void)RegisterViewController:(RacePadViewController *)view_controller WithTypeMask:(int)mask;
-(void)ReleaseViewController:(RacePadViewController *)view_controller;

-(void)AddView:(id)view WithType:(int)type;
-(void)RemoveView:(id)view;
-(void)SetViewDisplayed:(id)view;
-(void)SetViewHidden:(id)view;
-(void)EnableViewRefresh:(id)view;
-(void)DisableViewRefresh:(id)view;
-(void)SetParameter:(NSString *)parameter ForView:(id)view;
-(void)RequestRedraw:(id)view;
-(void)RequestRedrawType:(int)type;

-(RPCView *)FindView:(id)view;
-(RPCView *)FindView:(id)view WithIndexReturned:(int *)index;

-(int)DisplayedViewCount;

-(void)AddDataSourceWithType:(int)type AndParameter:(NSString *)parameter;
-(void)RemoveDataSourceWithType:(int)type;

-(void)CreateDataSources;
-(void)DestroyDataSources;

-(RPCDataSource *)FindDataSourceWithType:(int)type;
-(RPCDataSource *)FindDataSourceWithType:(int)type WithIndexReturned:(int *)index;

-(void) updateDriverNames;
-(void) requestPrediction: (NSString *)user;
-(void) sendPrediction;
-(void) updatePrediction;
-(void) checkUserName: (NSString *)name;
-(void) registeredUser;
-(void) badUser;

-(void) willResignActive;
-(void) didBecomeActive;

-(void) updateTabs;
-(void) selectTab:(int)index;
- (int) tabCount;
- (NSString *) tabTitle:(int)index;

-(void) updateSponsor;

-(void) synchroniseTime:(float)time;

-(void) restartCommentary;

@end
