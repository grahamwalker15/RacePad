//
//  DriverGapInfo.h
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class HeadToHeadView;

enum H2HFlag {
	H2H_PIT_ = 1,
	H2H_SC_ = 2,
};

@interface HeadToHeadLap : NSObject
{
	float gap;
	int pos0;
	int pos1;
	int flags0;
	int flags1;
}

@property float gap;
@property int pos0;
@property int pos1;
@property int flags0;
@property int flags1;

- (HeadToHeadLap *) initWithStream: (DataStream *) stream;

@end


@interface HeadToHead : NSObject
{
	NSString * driver0;
	NSString * driver1;
	
	NSString * abbr0;
	
	NSString * firstName0;
	NSString * surname0;
	NSString * teamName0;

	NSString * abbr1;
	
	NSString * firstName1;
	NSString * surname1;
	NSString * teamName1;
	
	int totalLapCount;
	int completedLapCount;
	NSMutableArray *laps;
}

@property (retain) NSString * driver0;
@property (retain) NSString * driver1;

@property (readonly) NSString * abbr0;

@property (readonly) NSString * firstName0;
@property (readonly) NSString * surname0;
@property (readonly) NSString * teamName0;

@property (readonly) NSString * abbr1;

@property (readonly) NSString * firstName1;
@property (readonly) NSString * surname1;
@property (readonly) NSString * teamName1;

@property (readonly) int completedLapCount;
@property (readonly) NSMutableArray *laps;

- (void) clearData;
- (void) loadData : (DataStream *) stream;

- (void) drawInView : (HeadToHeadView *)view;

@end
