//
//  RacePadTimeController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeViewController;
@class JogViewController;

@interface RacePadTimeController : NSObject
{
	TimeViewController * timeController;
	JogViewController * jogController;
	
	UIView * addOnOptionsView;
	
	NSTimer *hideTimer;

	bool displayed;
	bool hiding;
	
	float timeNow;
}

@property(nonatomic) bool displayed;
@property(nonatomic, readonly) float timeNow;

+(RacePadTimeController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController Animated:(bool)animated;
- (void) hide;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;
- (void) flagTimerExpired:(NSTimer *)theTimer;

- (void) setSliderMin:(float)startTime;
- (void) setSliderMax:(float)endTime;
- (void) setSliderMin:(float)startTime Max:(float)endTime;

- (void) updateTime:(float)time;
- (void) updateSlider:(float)time;
- (void) updateClock:(float)time;
- (void) updatePlayButton;

- (IBAction)PlayPressed:(id)sender;
- (IBAction)SliderChanged:(id)sender;
- (IBAction)JogControlChanged:(id)sender;
- (IBAction)ReplayPressed:(id)sender;

@end
