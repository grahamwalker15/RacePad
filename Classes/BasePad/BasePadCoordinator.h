//
//  BasePadCoordinator.h
//  BasePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"
#import "BasePadVideoViewController.h"
#import "HelpViewController.h"

@class BasePadViewController;
@class BasePadClientSocket;
@class BasePadDataHandler;
@class ElapsedTime;
@class DownloadProgress;
@class ServerConnect;
@class WorkOffline;

enum BPViewTypes
{
	BPC_VIDEO_VIEW_ = 0x1,
	BPC_SETTINGS_VIEW_ = 0x2,
	BPC_COMMENTARY_VIEW_ = 0x4,
} ;

// Connection types
enum ConnectionTypes
{
	BPC_NO_CONNECTION_,
	BPC_SOCKET_CONNECTION_,
	BPC_ARCHIVE_CONNECTION_,
	
	BPC_VIDEO_LIVE_CONNECTION_,
	BPC_VIDEO_ARCHIVE_CONNECTION_,
	
	BPC_CONNECTION_CONNECTING_,
	BPC_CONNECTION_SUCCEEDED_,
	BPC_CONNECTION_FAILED_,
} ;

@interface BPCView : NSObject
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

@interface BPCDataSource : NSObject
{
	BasePadDataHandler * dataHandler;
	NSString * fileName;
	int archiveType;
	int referenceCount;
}

@property (nonatomic, retain) BasePadDataHandler * dataHandler;;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic) int archiveType;
@property (nonatomic, readonly) int referenceCount;

-(id)initWithDataHandler:(BasePadDataHandler *)handler Type:(int)type Filename:(NSString *)name;

-(void)incrementReferenceCount;
-(void)decrementReferenceCount;

@end


@interface BasePadCoordinator : NSObject <HelpViewMaster>
{
	int connectionType;
	
	NSMutableArray * views;		// RPCView *
	NSMutableArray * dataSources;	// RPCDataSource *
	
	BasePadViewController * registeredViewController;
	int registeredViewControllerTypeMask;
	
	DownloadProgress *downloadProgress;
	ServerConnect *serverConnect;
	WorkOffline *workOffline;
	SettingsViewController *settingsViewController;
	BasePadVideoViewController *videoViewController;
	
	BasePadClientSocket * socket_;
	int connectionRetryCount;
	bool showingConnecting;
	
	int serverConnectionStatus;
	
	int videoConnectionType;
	int videoConnectionStatus;
	
	NSString *sessionPrefix;
	
	NSTimer *dataUpdateTimer;
	NSTimer *playUpdateTimer10hz;
	NSTimer *playUpdateTimer1hz;
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
	bool allowProtectMediaFromRestart;
	bool protectMediaFromRestart;
	
	bool reconnectOnBecomeActive;
	bool playOnBecomeActive;
	bool jumpOnBecomeActive;
	float restartTime;
	
	bool liveMovieSeekAllowed;
	
	NSString * nameToFollow;
	
	NSMutableArray *allTabs;
	unsigned char currentSponsor;
	
	bool lightRestart;
	
	float appVersionNumber;
}

@property (readonly) float appVersionNumber;

@property (nonatomic) int connectionType;
@property (nonatomic) float currentTime;
@property (nonatomic) float startTime;
@property (nonatomic) float endTime;
@property (nonatomic) float playbackRate;
@property (nonatomic) bool playing;
@property (nonatomic) bool needsPlayRestart;

@property (nonatomic) int serverConnectionStatus;
@property (nonatomic) bool showingConnecting;

@property (nonatomic) int videoConnectionType;
@property (nonatomic) int videoConnectionStatus;

@property (nonatomic) bool liveMovieSeekAllowed;

@property (readonly) float serverTimeOffset;

@property (readonly) BasePadViewController * registeredViewController;
@property (retain) SettingsViewController *settingsViewController;
@property (retain) BasePadVideoViewController *videoViewController;

@property (nonatomic, retain) NSString * nameToFollow;
@property (nonatomic) bool lightRestart;

+(BasePadCoordinator *)Instance;

-(void)onStartUp;
-(void)onDisplayFirstView;

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
-(void)SetServerAddress:(NSString *)server ShowWindow:(BOOL)showWindow LightRestart:(bool)lightRestart;
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

-(void)loadBPF:(NSString *)archive File:(NSString *)file SubIndex:(NSString *)subIndex;
-(void)loadSession:(NSString *)event Session: (NSString *)session;
-(void)onSessionLoaded;

-(NSString *)getVideoArchiveName;
-(NSString *)getAudioArchiveName;
-(NSString *)getVideoArchiveRoot;
-(NSString *)getAudioArchiveRoot;

-(void) prepareToPlayArchives;
-(void) showSnapshotOfArchives;

-(void) prepareToPlayUnconnected;
-(void) showSnapshotUnconnected;

-(void)setTimer: (float)thisTime;
-(void)dataUpdateTimerFired: (NSTimer *)theTimer;

-(void)playUpdateTimer10hzFired: (NSTimer *)theTimer;
-(void)playUpdateTimer1hzFired: (NSTimer *)theTimer;

-(float)currentPlayTime;

-(void)RegisterViewController:(BasePadViewController *)view_controller WithTypeMask:(int)mask;
-(void)ReleaseViewController:(BasePadViewController *)view_controller;

-(void)AddView:(id)view WithType:(int)type;
-(void)RemoveView:(id)view;
-(void)SetViewDisplayed:(id)view;
-(void)SetViewHidden:(id)view;
-(void)EnableViewRefresh:(id)view;
-(void)DisableViewRefresh:(id)view;
-(void)SetParameter:(NSString *)parameter ForView:(id)view;
-(void)RequestRedraw:(id)view;
-(void)RequestRedrawType:(int)type;

-(BPCView *)FindView:(id)view;
-(BPCView *)FindView:(id)view WithIndexReturned:(int *)index;

-(int)DisplayedViewCount;

-(void)AddDataSourceWithType:(int)type AndParameter:(NSString *)parameter;
-(void)RemoveDataSourceWithType:(int)type;

-(void)CreateDataSources;
-(void)DestroyDataSources;

-(BPCDataSource *)FindDataSourceWithType:(int)type;
-(BPCDataSource *)FindDataSourceWithType:(int)type WithIndexReturned:(int *)index;

-(void) willResignActive;
-(void) didBecomeActive;

-(void) updateTabs;
-(void) selectTab:(int)index;
- (int) tabCount;
- (NSString *) tabTitle:(int)index;
- (void) selectVideoTab;


-(void) updateSponsor;

-(void) synchroniseTime:(float)time;

-(void) resetCommentaryTimings;
-(void) restartCommentary;

-(void) resetListUpdateTimings;

-(void) clearStaticData;
-(void)AddDataSourceWithType:(int)type AndArchive:(NSString *)archive AndFile:(NSString *)file AndSubIndex:(NSString *)subIndex;
-(void)AddDataSourceWithType:(int)type AndFile:(NSString *)file;

- (bool) helpMasterPlaying;
- (void) helpMasterPausePlay;
- (void) helpMasterStartPlay;

@end
