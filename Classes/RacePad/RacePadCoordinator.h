//
//  RacePadCoordinator.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RacePadViewController.h"
#import "SettingsViewController.h"


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
	RPC_SETTINGS_VIEW_ = 0x16,
} ;

// Connection types
enum ConnectionTypes
{
	RPC_NO_CONNECTION_,
	RPC_SOCKET_CONNECTION_,
	RPC_ARCHIVE_CONNECTION_
} ;

// Orientation types
enum OrientationTypes
{
	RPC_ORIENTATION_PORTRAIT_,
	RPC_ORIENTATION_LANDSCAPE_
} ;

@interface RPCView : NSObject
{
	id view_;
	int type_;
	NSString * parameter_;
	bool displayed_;
}

@property (nonatomic, retain, setter=SetView, getter=View) id view_;
@property (nonatomic, retain, setter=SetParameter, getter=Parameter) NSString * parameter_;
@property (nonatomic, setter=SetType, getter=Type) int type_;
@property (nonatomic, setter=SetDisplayed, getter=Displayed) bool displayed_;

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
	bool firstView;
	
	RacePadClientSocket * socket_;
	
	NSString *sessionFolder;
	
	NSTimer *updateTimer;
	NSTimer *timeControllerTimer;
	
	int baseTime;
	ElapsedTime * elapsedTime;
	
	float currentTime;
	float startTime;
	float endTime;
	
	bool playing;
	bool needsPlayRestart;
}

@property (nonatomic) int connectionType;
@property (nonatomic) float currentTime;
@property (nonatomic) float startTime;
@property (nonatomic) float endTime;
@property (nonatomic) bool playing;
@property (nonatomic) bool needsPlayRestart;
@property (retain) SettingsViewController *settingsViewController;

+(RacePadCoordinator *)Instance;

-(void)onStartUp;

-(int) deviceOrientation;

-(void)startPlay;
-(void)pausePlay;
-(void)stopPlay;

-(void)prepareToPlay;
-(void)showSnapshot;

-(void)jumpToTime:(float)time;

-(void)serverConnected:(BOOL)ok;
-(BOOL)serverConnected;
-(void)SetServerAddress:(NSString *)server ShowWindow:(BOOL)showWindow;
-(void)Connected;
-(void)Disconnected;
-(void) connectionTimeout;

-(void) goOffline;

-(void) prepareToPlayFromSocket;
-(void) showSnapshotFromSocket;

-(void) acceptPushData:(NSString *)event Session:(NSString *)session;
-(void) projectDownloadStarting:(NSString *)event SessionName:(NSString *)session SizeInMB:(int) sizeInMB;
-(void) projectDownloadCancelled;
-(void)	projectDownloadComplete;
-(void) projectDownloadProgress:(int) sizeInMB;
-(void) cancelDownload;

-(void)loadRPF:(NSString *)file;
-(void)loadSession:(NSString *)event Session: (NSString *)session;
-(NSString *)getVideoArchiveName;

-(void) prepareToPlayArchives;
-(void) showSnapshotOfArchives;

-(void)setTimer: (float)thisTime;
-(void)timerUpdate: (NSTimer *)theTimer;

-(void)RegisterViewController:(UIViewController *)view_controller WithTypeMask:(int)mask;
-(void)ReleaseViewController:(UIViewController *)view_controller;

-(void)AddView:(id)view WithType:(int)type;
-(void)RemoveView:(id)view;
-(void)SetViewDisplayed:(id)view;
-(void)SetViewHidden:(id)view;
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

@end
