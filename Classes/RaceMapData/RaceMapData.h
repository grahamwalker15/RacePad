//
//  RaceMapData.h
//  RaceMap
//
//  Created by Simon Cuff 17/6/14.
//  Copyright 2014 SBG Sports Software Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadDatabase.h"
#import "TrackMap.h"
#import "DriverNames.h"
#import "DriverInfo.h"
#import "RaceMapAlertData.h"

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

@interface RaceMapData : BasePadDatabase
{
	TableData *driverListData;
	TableData *leaderBoardData;
	TableData *driverData;
	TrackMap *trackMap;
	DriverNames *driverNames;
	DriverInfo *driverInfo;
	TableData *competitorData;
	TableData *timingPage1;
	TableData *timingPage2;
	RaceMapAlertData * alertData;
	
	int session;
}

@property (readonly) TableData *driverListData;
@property (readonly) TableData *leaderBoardData;
@property (readonly) TableData *driverData;
@property (readonly) TrackMap *trackMap;
@property (readonly) DriverNames * driverNames;
@property (readonly) DriverInfo * driverInfo;
@property (readonly) TableData *competitorData;
@property (readonly) TableData *timingPage1;
@property (readonly) TableData *timingPage2;
@property (readonly) RaceMapAlertData * alertData;

@property int session;

+ (RaceMapData *)Instance;
- (void) clearStaticData;

@end

