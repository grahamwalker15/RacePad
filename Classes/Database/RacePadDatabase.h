//
//  RacePadDatabase.h
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableData.h"
#import "AlertData.h"
#import "CommentaryData.h"
#import "TrackMap.h"
#import "ImageListStore.h"
#import "PitWindow.h"
#import "Telemetry.h"
#import "DriverNames.h"
#import "DriverInfo.h"
#import "RacePrediction.h"

// Our cars
enum OurCars
{
	RPD_BLUE_CAR_,
	RPD_RED_CAR_
} ;

@interface RacePadDatabase : NSObject
{
	NSString *eventName;
	TableData *driverListData;
	TableData *leaderBoardData;
	TableData *driverData;
	TrackMap *trackMap;
	ImageListStore *imageListStore;
	PitWindow *pitWindow;
	AlertData * alertData;
	AlertData * rcMessages;
	CommentaryData * blueCommentary;
	CommentaryData * redCommentary;
	Telemetry *telemetry;
	DriverNames *driverNames;
	DriverInfo *driverInfo;
	RacePrediction *racePrediction;
	TableData *competitorData;
}

@property (retain) NSString *eventName;
@property (readonly) TableData *driverListData;
@property (readonly) TableData *leaderBoardData;
@property (readonly) TableData *driverData;
@property (readonly) TrackMap *trackMap;
@property (readonly) ImageListStore *imageListStore;
@property (readonly) PitWindow *pitWindow;
@property (readonly) AlertData * alertData;
@property (readonly) AlertData * rcMessages;
@property (readonly) CommentaryData * blueCommentary;
@property (readonly) CommentaryData * redCommentary;
@property (readonly) Telemetry * telemetry;
@property (readonly) DriverNames * driverNames;
@property (readonly) DriverInfo * driverInfo;
@property (readonly) RacePrediction * racePrediction;
@property (readonly) TableData *competitorData;

+ (RacePadDatabase *)Instance;
- (void) clearStaticData;

@end
