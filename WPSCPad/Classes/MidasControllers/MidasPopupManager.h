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

// View types
enum PopupViewTypes
{
	MIDAS_STANDINGS_POPUP_,
	MIDAS_CIRCUIT_POPUP_,
	MIDAS_FOLLOW_DRIVER_POPUP_,
	MIDAS_HEAD_TO_HEAD_POPUP_,
	MIDAS_VIP_POPUP_,
	MIDAS_MY_TEAM_POPUP_,
	MIDAS_ALERTS_POPUP_,
	MIDAS_TWITTER_POPUP_,
	MIDAS_FACEBOOK_POPUP_,
	MIDAS_CHAT_POPUP_,
};

@interface MidasPopupManager : NSObject <UIGestureRecognizerDelegate>
{
	BasePadViewController * managedViewController;
	int managedViewType;
	
	NSTimer *hideTimer;
	NSTimer *flagTimer;
	
	bool viewDisplayed;
	bool hiding;
	
	BasePadViewController * parentController;
}

@property(nonatomic) bool viewDisplayed;
@property(nonatomic) int managedViewType;
@property (nonatomic, assign) BasePadViewController *managedViewController;

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

@interface MidasStandingsManager : MidasPopupManager

{
	MidasStandingsViewController * standingsViewController;
}

@property (readonly, retain) MidasStandingsViewController *standingsViewController;

+(MidasStandingsManager *)Instance;

@end
