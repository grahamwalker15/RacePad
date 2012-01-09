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
@class MidasCircuitViewController;
@class MidasFollowDriverViewController;

// View types
enum PopupViewTypes
{
	MIDAS_POPUP_NONE_,
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

// View alignment
enum PopupViewAlignment
{
	MIDAS_ALIGN_LEFT_,
	MIDAS_ALIGN_RIGHT_,
	MIDAS_ALIGN_TOP_,
	MIDAS_ALIGN_BOTTOM_,
};

@interface MidasPopupManager : NSObject <UIGestureRecognizerDelegate>
{
	BasePadViewController * managedViewController;
	int managedViewType;
	
	NSTimer *hideTimer;
	NSTimer *flagTimer;
	
	bool viewDisplayed;
	bool hiding;
	
	int xAlignment;
	int yAlignment;
	
	float overhang;
	float preferredWidth;
	
	BasePadViewController * parentViewController;
}

@property(nonatomic) bool viewDisplayed;
@property(nonatomic) int managedViewType;
@property(nonatomic) float overhang;
@property(nonatomic) float preferredWidth;
@property (nonatomic, assign) BasePadViewController *managedViewController;
@property (readonly) BasePadViewController *parentViewController;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated XAlignment:(int)xAlign YAlignment:(int)yAlign;
- (void) moveToPositionX:(float)x Animated:(bool)animated;
- (void) hideAnimated:(bool)animated Notify:(bool)notify;

- (void) displayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;
- (void) flagTimerExpired:(NSTimer *)theTimer;
- (void) resetHidingFlag;

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;

- (float) widthOfView;
- (float) heightOfView;

@end

@interface MidasStandingsManager : MidasPopupManager

{
	MidasStandingsViewController * standingsViewController;
}

+(MidasStandingsManager *)Instance;

@end

@interface MidasCircuitViewManager : MidasPopupManager

{
	MidasCircuitViewController * circuitViewController;
}

+(MidasCircuitViewManager *)Instance;

@end

@interface MidasFollowDriverManager : MidasPopupManager

{
	MidasFollowDriverViewController * followDriverViewController;
}

+(MidasFollowDriverManager *)Instance;

@end
