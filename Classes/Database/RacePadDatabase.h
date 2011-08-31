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

@interface RacePadDatabase : BasePadDatabase
{
	TableData *driverListData;
	TableData *leaderBoardData;
	TableData *driverData;
	DriverGapInfo *driverGapInfo;
	TrackMap *trackMap;
	PitWindow *pitWindow;
	AlertData * alertData;
	AlertData * rcMessages;
	CommentaryData * commentary;
	Telemetry *telemetry;
	DriverNames *driverNames;
	DriverInfo *driverInfo;
	RacePrediction *racePrediction;
	TableData *competitorData;
	HeadToHead *headToHead;
}

@property (readonly) TableData *driverListData;
@property (readonly) TableData *leaderBoardData;
@property (readonly) TableData *driverData;
@property (readonly) DriverGapInfo * driverGapInfo;
@property (readonly) TrackMap *trackMap;
@property (readonly) PitWindow *pitWindow;
@property (readonly) AlertData * alertData;
@property (readonly) AlertData * rcMessages;
@property (readonly) CommentaryData * commentary;
@property (readonly) Telemetry * telemetry;
@property (readonly) DriverNames * driverNames;
@property (readonly) DriverInfo * driverInfo;
@property (readonly) RacePrediction * racePrediction;
@property (readonly) TableData *competitorData;
@property (readonly) HeadToHead *headToHead;


+ (RacePadDatabase *)Instance;
- (void) clearStaticData;

@end

