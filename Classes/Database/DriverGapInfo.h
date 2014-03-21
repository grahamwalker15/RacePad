//
//  DriverGapInfo.h
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

@interface DriverGapInfo : NSObject
{
	NSString * requestedDriver;
	
	NSString * abbr;
	
	NSString * firstName;
	NSString * surname;
	NSString * teamName;
	
	int position;
	int laps;
	bool inPit;
	bool stopped;
	
	NSString * carAhead;
	NSString * carBehind;
	
	float gapAhead;
	float gapBehind;
}

@property (retain) NSString * requestedDriver;

@property (readonly) NSString * abbr;

@property (readonly) NSString * firstName;
@property (readonly) NSString * surname;
@property (readonly) NSString * teamName;

@property (readonly) NSString * carAhead;
@property (readonly) NSString * carBehind;

@property (readonly) int position;
@property (readonly) int laps;
@property (readonly) bool inPit;
@property (readonly) bool stopped;

@property (readonly) float gapAhead;
@property (readonly) float gapBehind;

- (void) clearData;
- (void) loadData : (DataStream *) stream;

@end
