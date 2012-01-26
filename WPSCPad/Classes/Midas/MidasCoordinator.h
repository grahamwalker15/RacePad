//
//  MidasCoordinator.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RacePadCoordinator.h"

@class MidasVideoViewController;
@class MidasCoordinator;
@class MidasSocialmediaMessage;

enum MidasSocialMediaTypes
{
	MIDAS_SM_TWITTER_ = 0x1,
	MIDAS_SM_FACEBOOK_ = 0x2,
	MIDAS_SM_MIDAS_CHAT_ = 0x4,
	MIDAS_SM_ALL_ = 0xFFFF,
} ;

@protocol MidasSocialmediaSourceDelegate
- (void)resetMessageCount;
- (bool)queueNewMessages:(NSMutableArray *)messageQueue AtTime:(float)updateTime;
@end

@protocol MidasSocialmediaResponderDelegate
- (void)notifyNewSocialmediaMessage:(MidasSocialmediaMessage *)message;
@end

@interface MidasSocialmediaMessage : NSObject
{
	int messageType;
	float messageTime;
	NSString * messageSender;
	int messageID;
}

@property (nonatomic) int messageType;
@property (nonatomic) float messageTime;
@property (nonatomic, retain) NSString * messageSender;
@property (nonatomic) int messageID;

-(id)initWithSender:(NSString *)sender Type:(int)type Time:(float)time ID:(int)identifier;

@end

@interface MidasSocialmediaSource : NSObject
{
	id  socialmediaSource;
	int socialmediaType;
}

@property (nonatomic, retain) id socialmediaSource;
@property (nonatomic) int socialmediaType;

-(id)initWithSource:(id)source Type:(int)type;

@end

@interface MidasCoordinator : RacePadCoordinator
{
	MidasVideoViewController * midasVideoViewController;
	
	NSMutableArray * socialmediaMessageQueue;		// MidasSocialmediaMessage *
	NSMutableArray * socialmediaSources;			// MidasSocialmediaSource *
	
	bool socialmediaMessageQueueBlocked;
	
	BasePadViewController <MidasSocialmediaResponderDelegate> * socialmediaResponder;
	int socialmediaResponderMask;
}

+(MidasCoordinator *)Instance;

-(void)RegisterSocialmediaResponder:(BasePadViewController  <MidasSocialmediaResponderDelegate> *)responder WithTypeMask:(int)mask;
-(void)ReleaseSocialmediaResponder:(BasePadViewController  <MidasSocialmediaResponderDelegate> *)responder;

-(void)AddSocialmediaSource:(id)source WithType:(int)type;
-(void)RemoveSocialmediaSource:(id)source;

-(MidasSocialmediaSource *)findSocialmediaSource:(id)source;
-(MidasSocialmediaSource *)findSocialmediaSource:(id)source WithIndexReturned:(int *)index;

- (void)blockSocialmediaQueue;
- (void)releaseSocialmediaQueue;

- (void)checkSocialmediaMessageQueue;

@end
