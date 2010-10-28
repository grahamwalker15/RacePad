//
//  RacePadTimeController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeViewController;

@interface RacePadTimeController : NSObject
{
	TimeViewController * timeController;
	
	NSTimer *hideTimer;

	bool displayed;
}

@property(nonatomic) bool displayed;

+(RacePadTimeController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController Animated:(bool)animated;
- (void) hide;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;


- (void) setSliderMin:(float)startTime Max:(float)endTime;

- (void) updateTime:(float)time;
- (void) updateSlider:(float)time;
- (void) updateClock:(float)time;

- (IBAction)PlayPressed:(id)sender;
- (IBAction)SliderChanged:(id)sender;

@end
