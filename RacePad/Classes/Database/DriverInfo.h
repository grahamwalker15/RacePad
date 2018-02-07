//
//  DriverInfo.h
//  RacePad
//
//  Created by Gareth Griffith on 2/7/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DriverInfoRecord : NSObject
{
	NSString * abbr;

	int age;
	int races;
	int championships;
	int wins;
	int poles;
	int fastestLaps;
	float points;	
	int lastPos;	
	float lastPoints;	
}

@property (retain) NSString * abbr;

@property (nonatomic) int age;
@property (nonatomic) int races;
@property (nonatomic) int championships;
@property (nonatomic) int wins;
@property (nonatomic) int poles;
@property (nonatomic) int fastestLaps;
@property (nonatomic) float points;
@property (nonatomic) int lastPos;
@property (nonatomic) float lastPoints;

- (id) initWithName:(NSString *)name Age:(int)ageIn Races:(int)racesIn Championships:(int)championshipsIn Wins:(int)winsIn Poles:(int)polesIn FastestLaps:(int)fastestLapsIn Points:(float)pointsIn LastPos:(int)lastPosIn LastPoints:(float)lastPointsIn;

@end

@interface DriverInfo : NSObject
{
	NSMutableArray *drivers;
	int count;
}

@property (readonly) int count;

- (void)addDriverWithName:(NSString *)name Age:(int)ageIn Races:(int)racesIn Championships:(int)championshipsIn Wins:(int)winsIn Poles:(int)polesIn FastestLaps:(int)fastestLapsIn Points:(float)pointsIn LastPos:(int)lastPosIn LastPoints:(float)lastPointsIn;
- (DriverInfoRecord *)driverInfoByAbbName:(NSString *) abbName;
- (void) fillWithDefaultData;

@end
