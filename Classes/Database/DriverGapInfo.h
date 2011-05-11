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
	bool inPit;
	bool stopped;
	
	NSString * carAhead;
	NSString * carBehind;
	
	float gapAhead;
	float gapBehind;
}

@property (retain) NSString * requestedDriver;

@property (retain) NSString * abbr;

@property (retain) NSString * firstName;
@property (retain) NSString * surname;
@property (retain) NSString * teamName;

@property (retain) NSString * carAhead;
@property (retain) NSString * carBehind;

@property (nonatomic) int position;
@property (nonatomic) bool inPit;
@property (nonatomic) bool stopped;

@property (nonatomic) float gapAhead;
@property (nonatomic) float gapBehind;

- (void) clearData;
- (void) loadData : (DataStream *) stream;

@end
