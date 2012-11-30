//
//  BasePadPopupManager.h
//  MidasDemo
//
//  Created by Gareth Griffith on 10/12/12.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasePadViewController.h"
#import "BasePadPopupViewController.h"

// View alignment
enum PopupViewAlignment
{
	POPUP_ALIGN_LEFT_,
	POPUP_ALIGN_RIGHT_,
	POPUP_ALIGN_TOP_,
	POPUP_ALIGN_BOTTOM_,
	POPUP_ALIGN_FULL_SCREEN_,
	
	POPUP_DIRECTION_UP_,
	POPUP_DIRECTION_DOWN_,
	POPUP_DIRECTION_LEFT_,
	POPUP_DIRECTION_RIGHT_,
};

// View alignment
enum PopupMenuZones
{
	POPUP_ZONE_NONE_ = 0x0,
	POPUP_ZONE_ALL_ = 0xFFFF
};

// View types
enum PopupViewTypes // Defined by derived class
{
	POPUP_NONE_
};


@protocol BasePadPopupParentDelegate
- (void)notifyShowingPopup:(int)popupType;
- (void)notifyShowedPopup:(int)popupType;
- (void)notifyHidingPopup:(int)popupType;
- (void)notifyHidPopup:(int)popupType;
- (void)notifyResizingPopup:(int)popupType;
- (void)notifyExclusiveUse:(int)popupType InZone:(int)popupZone;
@end

@interface BasePadPopupManager : NSObject <UIGestureRecognizerDelegate>
{
	BasePadPopupViewController * managedViewController;
	int managedViewType;
	int managedExclusionZone;
	
	NSTimer *hideTimer;
	NSTimer *flagTimer;
	
	bool viewDisplayed;
	
	bool hiding;
	bool notifyAfterHide;
	
	int xAlignment;
	int yAlignment;
	int revealDirection;
	
	float overhang;
	float preferredWidth;
	
	bool showHeadingAtStart;
	
	BasePadViewController <BasePadPopupParentDelegate>  * parentViewController;
}

@property(nonatomic) bool viewDisplayed;
@property(nonatomic) int managedViewType;
@property(nonatomic) int managedExclusionZone;
@property(nonatomic) float overhang;
@property(nonatomic) float preferredWidth;
@property (nonatomic, assign) BasePadPopupViewController *managedViewController;
@property (readonly) BasePadViewController <BasePadPopupParentDelegate> *parentViewController;
@property(nonatomic) bool showHeadingAtStart;

- (void) onStartUp;

- (void) grabExclusion:(UIViewController <BasePadPopupParentDelegate> *)viewController;
- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated Direction:(int)direction XAlignment:(int)xAlign YAlignment:(int)yAlign;
- (void) moveToPositionX:(float)x Animated:(bool)animated;
- (void) hideAnimated:(bool)animated Notify:(bool)notify;
- (void) bringToFront;

- (void) displayAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) setHideTimer;
- (void) hideTimerExpired:(NSTimer *)theTimer;
- (void) flagTimerExpired:(NSTimer *)theTimer;
- (void) resetHidingFlag;

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer;

- (float) preferredWidthOfView;
- (float) widthOfView;
- (float) heightOfView;

@end

