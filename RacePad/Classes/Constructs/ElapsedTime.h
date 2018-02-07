//
//  ElapsedTime.h
//  RacePad
//
//  Created by Gareth Griffith on 10/20/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ElapsedTime : NSObject
{
	CFAbsoluteTime time_start_;
}

- (void) reset;
- (double) value;  // in seconds
   
+ (double) TimeOfDay;  // in seconds
+ (double) LocalTimeOfDay;  // in seconds
   
+ (void) GetYear:(int *)year Month:(int *)month Day:(int *)day;

@end


@interface PulseTimer : ElapsedTime
{
	double interval_;	
}

- (id) initWithInterval:(double)interval;

- (bool) state;

@end

@interface BounceTimer : ElapsedTime
{
	double min_value_;
	double max_value_;
	double interval_;
	
}

- (id) initWithMinValue:(double)min_value MaxValue:(double)max_value Interval:(double)interval;

- (double) state;

@end

@interface LoopTimer : ElapsedTime
{
	double min_value_;
	double max_value_;
	double interval_;
	
};

- (id) initWithMinValue:(double)min_value MaxValue:(double)max_value Interval:(double)interval;

- (double) state;

@end


