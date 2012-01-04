//
//  BasePadTimeController.h
//  BasePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadViewController.h"

@class TimeViewController;
@class JogViewController;

@interface BasePadTimeController : NSObject <UIGestureRecognizerDelegate, TimeControllerInstance>

{
	TimeViewController * timeController;
	JogViewController * jogController;
	
	UIView * addOnOptionsView;
	
	NSTimer *hideTimer;

	bool displayed;
	bool hiding;
	
	float timeNow;
	
	BasePadViewController * parentController;
}

@property(nonatomic) bool displayed;
@property(nonatomic, readonly) float timeNow;
@property (readonly, retain) TimeViewController *timeController;

+(BasePadTimeController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController Animated:(bool)animated;
- (void) hide;
- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;
- (void) flagTimerExpired:(NSTimer *)theTimer;
- (void) resetHidingFlag;

- (void) setSliderMin:(float)startTime;
- (void) setSliderMax:(float)endTime;
- (void) setSliderMin:(float)startTime Max:(float)endTime;

- (void) updateTime:(float)time;
- (void) updateSlider:(float)time;
- (void) updateClock:(float)time;
- (void) updatePlayButtons;
- (void) updateLiveButton;

- (IBAction)PlayPressed:(id)sender;
- (IBAction)SlowMotionPlayPressed:(id)sender;
- (IBAction)SliderChanged:(id)sender;
- (void)actOnSliderValue;

- (IBAction)JogControlChanged:(id)sender;
- (IBAction)ReplayPressed:(id)sender;
- (IBAction)JumpButtonPressed:(id)sender;
- (IBAction)goLivePressed:(id)sender;

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;

- (bool) timeControllerDisplayed;
- (void) displayTimeControllerInViewController:(UIViewController *)viewController Animated:(bool)animated;
- (void) hideTimeController;

@end
