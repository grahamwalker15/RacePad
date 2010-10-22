//
//  RacePadCoordinator.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// View types
enum ViewTypes
{
	RPC_DRIVER_LIST_VIEW_,
	RPC_TRACK_MAP_VIEW_
} ;

@interface RacePadView : NSObject
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

@class RacePadClientSocket;
@class RacePadDataHandler;
@class ElapsedTime;

@interface RacePadCoordinator : NSObject
{
	NSMutableArray * views_;
	RacePadClientSocket * socket_;
	
	NSString *sessionFolder;
	
	NSTimer *updateTimer;
	RacePadDataHandler *dataHandler;
	int baseTime;
	ElapsedTime *currentTime;
}

+(RacePadCoordinator *)Instance;

- (void) onStartUp;

-(void)AddView:(id)view WithType:(int)type;
-(void)RemoveView:(id)view;
-(void)SetViewDisplayed:(id)view;
-(void)SetViewHidden:(id)view;
-(void)RequestRedraw:(id)view;
-(void)RequestRedrawType:(int)type;

-(void)SetServerAddress:(NSString *)server;
-(void)ConnectSocket;
-(void)Connected;

-(RacePadView *)FindView:(id)view;
-(RacePadView *)FindView:(id)view WithIndexReturned:(int *)index;

- (void) playRPF: (NSString *)file;
- (void) timerUpdate: (NSTimer *)theTimer;

@end
