//
//  RacePadCoordinator.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RacePadClientSocket;
@class RacePadDataHandler;
@class ElapsedTime;

// View types
enum ViewTypes
{
	RPC_DRIVER_LIST_VIEW_,
	RPC_LAP_LIST_VIEW_,
	RPC_TRACK_MAP_VIEW_
} ;

// Connection types
enum ConnectionTypes
{
	RPC_NO_CONNECTION_,
	RPC_SOCKET_CONNECTION_,
	RPC_ARCHIVE_CONNECTION_
} ;

@interface RPCView : NSObject
{
	id view_;
	int type_;
	bool displayed_;
}

@property (nonatomic, retain, setter=SetView, getter=View) id view_;
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
	
	RacePadClientSocket * socket_;
	
	NSString *sessionFolder;
	
	NSTimer *updateTimer;
	
	int baseTime;
	ElapsedTime * elapsedTime;
	
	float currentTime;
	float startTime;
	float endTime;
	
	bool playing;
	bool shouldPlay;
}

@property (nonatomic) int connectionType;
@property (nonatomic) float currentTime;
@property (nonatomic) float startTime;
@property (nonatomic) float endTime;
@property (nonatomic) bool playing;
@property (nonatomic) bool shouldPlay;

+(RacePadCoordinator *)Instance;

-(void)onStartUp;

-(void)startPlay;
-(void)stopPlay;

-(void)serverConnected:(BOOL)ok;
-(void)SetServerAddress:(NSString *)server;
-(void)ConnectSocket;
-(void)Connected;

-(void) acceptPushData:(NSString *)event Session:(NSString *)session;

-(void)loadRPF: (NSString *)file;
-(void)loadSession: (NSString *)event Session: (NSString *)session;

-(void) prepareToPlayArchives;
-(void) showSnapshotOfArchives;

-(void)timerUpdate: (NSTimer *)theTimer;

-(void)AddView:(id)view WithType:(int)type;
-(void)RemoveView:(id)view;
-(void)SetViewDisplayed:(id)view;
-(void)SetViewHidden:(id)view;
-(void)RequestRedraw:(id)view;
-(void)RequestRedrawType:(int)type;

-(void) requestDriverView:(NSString *) driver;
-(void) nextDriverView:(NSString *) driver;
-(void) prevDriverView:(NSString *) driver;

-(RPCView *)FindView:(id)view;
-(RPCView *)FindView:(id)view WithIndexReturned:(int *)index;

-(int)DisplayedViewCount;


-(void)AddDataSourceWithType:(int)type;
-(void)RemoveDataSourceWithType:(int)type;

-(void)CreateDataSources;
-(void)DestroyDataSources;

-(RPCDataSource *)FindDataSourceWithType:(int)type;
-(RPCDataSource *)FindDataSourceWithType:(int)type WithIndexReturned:(int *)index;

@end
