//
//  RacePadDatabase.h
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadDatabase.h"
#import "AlertData.h"
#import "CommentaryData.h"
#import "TrackMap.h"
#import "PitWindow.h"
#import "Telemetry.h"
#import "DriverNames.h"
#import "DriverGapInfo.h"
#import "DriverInfo.h"
#import "RacePrediction.h"
#import "HeadToHead.h"

// Our cars
enum OurCars
{
	RPD_BLUE_CAR_,
	RPD_RED_CAR_
} ;

enum SessionTypes {
	RPD_SESSION_RACE_,
	RPD_SESSION_QUALLY_,
	RPD_SESSION_PRACTICE_,
	RPD_SESSION_TEST_,
	RPD_SESSION_OTHER_,
};

@interface RacePadDatabase : BasePadDatabase
{
	TableData *driverListData;
	TableData *leaderBoardData;
	TableData *driverData;
	TableData *midasStandingdData;
	DriverGapInfo *driverGapInfo;
	TrackMap *trackMap;
	PitWindow *pitWindow;
	AlertData * alertData;
	AlertData * rcMessages;
	CommentaryData * commentary;
	AlertData * accidents;
	Telemetry *telemetry;
	DriverNames *driverNames;
	DriverInfo *driverInfo;
	RacePrediction *racePrediction;
	TableData *competitorData;
	HeadToHead *headToHead;
	TableData *midasVotingTable;
	TableData *timingPage1;
	TableData *timingPage2;
	
	int session;
}

@property (readonly) TableData *driverListData;
@property (readonly) TableData *leaderBoardData;
@property (readonly) TableData *driverData;
@property (readonly) TableData *midasStandingsData;
@property (readonly) DriverGapInfo * driverGapInfo;
@property (readonly) TrackMap *trackMap;
@property (readonly) PitWindow *pitWindow;
@property (readonly) AlertData * alertData;
@property (readonly) AlertData * rcMessages;
@property (readonly) AlertData * accidents;
@property (readonly) CommentaryData * commentary;
@property (readonly) Telemetry * telemetry;
@property (readonly) DriverNames * driverNames;
@property (readonly) DriverInfo * driverInfo;
@property (readonly) RacePrediction * racePrediction;
@property (readonly) TableData *competitorData;
@property (readonly) HeadToHead *headToHead;
@property (readonly) TableData *midasVotingTable;
@property (readonly) TableData *timingPage1;
@property (readonly) TableData *timingPage2;

@property int session;

+ (RacePadDatabase *)Instance;
- (void) clearStaticData;

@end

