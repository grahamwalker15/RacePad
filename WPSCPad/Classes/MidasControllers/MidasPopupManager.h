//
//  MidasPopupManager.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BasePadViewController.h"

@class MidasStandingsViewController;

@interface MidasPopupManager : NSObject <UIGestureRecognizerDelegate>
{
	BasePadViewController * managedViewController;
	
	NSTimer *hideTimer;
	NSTimer *flagTimer;
	
	bool displayed;
	bool hiding;
	
	BasePadViewController * parentController;
}

@property(nonatomic) bool displayed;
@property (nonatomic, retain) BasePadViewController *managedViewController;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Y:(float)y Animated:(bool)animated;
- (void) hideAnimated:(bool)animated;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;
- (void) flagTimerExpired:(NSTimer *)theTimer;
- (void) resetHidingFlag;

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;

- (float) widthOfView;

@end
