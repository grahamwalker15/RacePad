//
//  MidasCountdownTimer.m
//  Midas
//
//  Created by Daniel Tull on 12.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasCountdownTimer.h"

@implementation MidasCountdownTimer {
	NSTimeInterval _timeInterval;
	__strong NSDate *_eventDate;
	__strong NSTimer *_timer;
	NSTimeInterval _previousTimeInterval;
	__strong NSCalendar *_calendar;
}

- (id)initWithTimeIntervalToEvent:(NSTimeInterval)timeInterval {
	self = [super init];
	if (!self) return nil;
	_timeInterval = timeInterval;
	_eventDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
	_timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(_timerFired:) userInfo:nil repeats:YES];
	_calendar = [NSCalendar autoupdatingCurrentCalendar];
	return self;
}

- (void)_timerFired:(NSTimer *)timer {
	[self _calculateCountdown];
}

- (void)_calculateCountdown {
	
	NSTimeInterval timeInterval = [_eventDate timeIntervalSinceDate:[NSDate date]];
	timeInterval = floor(timeInterval);
	
	if (timeInterval == _previousTimeInterval)
		return;
	
	_previousTimeInterval = timeInterval;
	
	if (self.timeChangedHandler != NULL) {
		
		
		NSDateComponents *components = [_calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)
													fromDate:[NSDate date]
													  toDate:_eventDate
													 options:0];
		
		
		
		self.timeChangedHandler([components day], [components hour], [components minute], [components second]);
	}
	
	if (timeInterval <= 0.0f && self.eventDateHandler != NULL) {
		self.eventDateHandler();
		[_timer invalidate];
		_timer = nil;
	}
}

@end
