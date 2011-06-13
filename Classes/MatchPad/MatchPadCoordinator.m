//
//  MatchPadCoordinator.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"
#import "MatchPadAppDelegate.h"
#import "MatchPadSponsor.h"
#import "BasePadViewController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadClientSocket.h"
#import "MatchPadDataHandler.h"
#import "ElapsedTime.h"
#import "TableDataView.h"
#import "MatchPadDatabase.h"
#import "CompositeViewController.h"
#import "DownloadProgress.h"
#import "ServerConnect.h"
#import "WorkOffline.h"
#import "BasePadPrefs.h"
#import "TabletState.h"

#import "UIConstants.h"

@interface UIApplication (extended)
-(void) terminateWithSuccess;
@end


@implementation MatchPadCoordinator

static MatchPadCoordinator * instance_ = nil;

+(MatchPadCoordinator *)Instance
{
	if(!instance_)
		instance_ = [[MatchPadCoordinator alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self =[super init])
	{	
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void) clearStaticData
{
	[super clearStaticData];
}

- (void) requestInitialData
{
	[(MatchPadClientSocket*)socket_ SynchroniseTime];
	[(MatchPadClientSocket*)socket_ RequestEvent];
	[(MatchPadClientSocket*)socket_ RequestUIImages];
}

- (void) requestConnectedData
{
}

- (void) redrawCommentary
{
}

- (void) restartCommentary
{
}

- (NSString *)archiveName
{
	return @"match_pad.rpa";
}

- (NSString *)baseChunkName
{
	return @"match_pad";
}

- (BasePadDataHandler *)allocateDataHandler
{
	return [MatchPadDataHandler alloc];
}

- (int) serverPort
{
	return 6022;
}

- (BasePadClientSocket*) createClientSocket
{
	return [[MatchPadClientSocket alloc] CreateSocket];
}

-(void) streamData:(BPCView *)existing_view
{
	if([existing_view Type] == MPC_PITCH_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ StreamPitch];
	}
}

-(void) requestData:(BPCView *)existing_view
{
	if([existing_view Type] == MPC_PITCH_VIEW_)
	{
		[(MatchPadClientSocket *)socket_ RequestPitch];
	}
}

- (void) addDataSource:(int)type Parameter:(NSString *)parameter
{
	if (type == MPC_PITCH_VIEW_)
	{
		[self AddDataSourceWithType:type AndFile: @"pitch"];
	}
}

@end


