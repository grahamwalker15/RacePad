//
//  ElapsedTime.m
//  RacePad
//
//  Created by Gareth Griffith on 10/20/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "ElapsedTime.h"


///////////////////////////////////////////////////
//
// ElapsedTime implementation
//
///////////////////////////////////////////////////

@implementation ElapsedTime

- (id) init
{
	if(self = [super init])
	{
		[self reset];
	}
	
	return self;
}

- (void) reset
{
	time_start_ = CFAbsoluteTimeGetCurrent();
}

- (double) value  // in seconds
{
	CFAbsoluteTime time_now = CFAbsoluteTimeGetCurrent();
	return (double)(time_now - time_start_);
}

+ (double) TimeOfDay  // in seconds
{
	CFAbsoluteTime time_now = CFAbsoluteTimeGetCurrent();
	CFGregorianDate date_time = CFAbsoluteTimeGetGregorianDate (time_now, nil);
	
	date_time.hour = 0;
	date_time.minute = 0;
	date_time.second = 0;
	
	CFAbsoluteTime time_midnight = CFGregorianDateGetAbsoluteTime (date_time,nil);
	
	return time_now - time_midnight;
}

+ (double) LocalTimeOfDay  // in seconds
{
	CFAbsoluteTime time_now = CFAbsoluteTimeGetCurrent();
	CFGregorianDate date_time = CFAbsoluteTimeGetGregorianDate (time_now, nil);
	
	date_time.hour = 0;
	date_time.minute = 0;
	date_time.second = 0;
	
	CFAbsoluteTime time_midnight = CFGregorianDateGetAbsoluteTime (date_time,nil);
	
	return time_now - time_midnight;
}

+ (void) GetYear:(int *)year Month:(int *)month Day:(int *)day;
{
	CFAbsoluteTime time_now = CFAbsoluteTimeGetCurrent();
	CFGregorianDate date_time = CFAbsoluteTimeGetGregorianDate (time_now, nil);
		
	*year = (int)date_time.year;
	*month = (int)date_time.month;
	*day = (int)date_time.day;
}

@end


///////////////////////////////////////////////////
//
// PulseTimer implementation
//
///////////////////////////////////////////////////

@implementation PulseTimer

- (id) initWithInterval:(double)interval
{
	if(self = [super init])
	{
		interval_ = interval;;
	}
	
	return self;
}


- (bool) state
{
	if(interval_ < 0.0001)
	{
		return true;
	}
	else
	{
		double pulse = [self Value] / (interval_ * 2.0);
		return ((pulse - floor(pulse)) < 0.5) ;
	}
}

@end


///////////////////////////////////////////////////
//
// BounceTimer implementation
//
///////////////////////////////////////////////////

@implementation BounceTimer

- (id) initWithMinValue:(double)min_value MaxValue:(double)max_value Interval:(double)interval
{
	if(self = [super init])
	{
		min_value_ = min_value;;
		max_value_ = max_value;;
		interval_ = interval;;
	}
	
	return self;
}

- (double) state
{
	if(interval_ < 0.0001)
	{
		return min_value_;
	}
	else
	{
		double value = [self Value] / interval_ ;
		double cycles = floor(value);
		value -= cycles ;
		
		bool even = (((cycles * 0.5) - floor(cycles * 0.5)) < 0.1);
		
		if(even)
			return (value * (max_value_ - min_value_) + min_value_) ;
		else
			return (max_value_ - value * (max_value_ - min_value_)) ;
	}
}

@end


///////////////////////////////////////////////////
//
// LoopTimer implementation
//
///////////////////////////////////////////////////

@implementation LoopTimer

- (id) initWithMinValue:(double)min_value MaxValue:(double)max_value Interval:(double)interval
{
	if(self = [super init])
	{
		min_value_ = min_value;;
		max_value_ = max_value;;
		interval_ = interval;;
	}
	
	return self;
}

- (double) state
{
	if(interval_ < 0.0001)
	{
		return min_value_;
	}
	else
	{
		double value = [self Value] / interval_ ;
		int cycles = (int)floor(value);
		value -= (double)cycles ;
		
		return (value * (max_value_ - min_value_) + min_value_) ;
	}
}

@end

