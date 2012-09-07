//
//  MidasPopupManager.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BasePadViewController.h"

@class MidasMasterMenuViewController;
@class MidasStandingsViewController;
@class MidasCircuitViewController;
@class MidasFollowDriverViewController;
@class MidasCameraViewController;
@class MidasHeadToHeadViewController;
@class MidasMyTeamViewController;
@class MidasVIPViewController;
@class MidasAlertsViewController;
@class MidasSocialController;
@class MidasTwitterViewController;
@class MidasFacebookViewController;
@class MidasChatViewController;
@class MidasSocialViewController;
@class MidasHelpViewController;

// View types
enum PopupViewTypes
{
	MIDAS_POPUP_NONE_,
	MIDAS_STANDINGS_POPUP_,
	MIDAS_CIRCUIT_POPUP_,
	MIDAS_FOLLOW_DRIVER_POPUP_,
	MIDAS_CAMERA_POPUP_,
	MIDAS_HEAD_TO_HEAD_POPUP_,
	MIDAS_VIP_POPUP_,
	MIDAS_MY_TEAM_POPUP_,
	MIDAS_ALERTS_POPUP_,
	MIDAS_SOCIAL_MEDIA_POPUP_,
	MIDAS_HELP_POPUP_,
	MIDAS_CHAT_POPUP_,
	MIDAS_MASTER_MENU_POPUP_,
};

// View alignment
enum PopupViewAlignment
{
	MIDAS_ALIGN_LEFT_,
	MIDAS_ALIGN_RIGHT_,
	MIDAS_ALIGN_TOP_,
	MIDAS_ALIGN_BOTTOM_,
	MIDAS_ALIGN_FULL_SCREEN_,
	
	MIDAS_DIRECTION_UP_,
	MIDAS_DIRECTION_DOWN_,
	MIDAS_DIRECTION_LEFT_,
	MIDAS_DIRECTION_RIGHT_,
};
	
// View alignment
enum PopupMenuZones
{
	MIDAS_ZONE_NONE_ = 0x0,
	MIDAS_ZONE_ALL_ = 0xFFFF,
	MIDAS_ZONE_BOTTOM_ = 0x1,
	MIDAS_ZONE_TOP_ = 0x2,
	MIDAS_ZONE_SOCIAL_MEDIA_ = 0x4,
	MIDAS_ZONE_DATA_AREA_ = 0x8,
	MIDAS_ZONE_MY_AREA_ = 0x10,
};

@protocol MidasPopupParentDelegate
- (void)notifyShowingPopup:(int)popupType;
- (void)notifyShowedPopup:(int)popupType;
- (void)notifyHidingPopup:(int)popupType;
- (void)notifyResizingPopup:(int)popupType;
- (void)notifyExclusiveUse:(int)popupType InZone:(int)popupZone;
@end

@protocol MidasPopupManagedDelegate
- (void)onDisplay;
- (void)onHide;
@end

@interface MidasPopupManager : NSObject <UIGestureRecognizerDelegate>
{
	BasePadViewController <MidasPopupManagedDelegate> * managedViewController;
	int managedViewType;
	int managedExclusionZone;
	
	NSTimer *hideTimer;
	NSTimer *flagTimer;
	
	bool viewDisplayed;
	bool hiding;
	
	int xAlignment;
	int yAlignment;
	int revealDirection;
	
	float overhang;
	float preferredWidth;
	
	BasePadViewController <MidasPopupParentDelegate>  * parentViewController;
}

@property(nonatomic) bool viewDisplayed;
@property(nonatomic) int managedViewType;
@property(nonatomic) int managedExclusionZone;
@property(nonatomic) float overhang;
@property(nonatomic) float preferredWidth;
@property (nonatomic, assign) BasePadViewController <MidasPopupManagedDelegate> *managedViewController;
@property (readonly) BasePadViewController <MidasPopupParentDelegate> *parentViewController;

- (void) onStartUp;

- (void) grabExclusion:(UIViewController <MidasPopupParentDelegate> *)viewController;
- (void) displayInViewController:(UIViewController *)viewController AtX:(float)x Animated:(bool)animated Direction:(int)direction XAlignment:(int)xAlign YAlignment:(int)yAlign;
- (void) moveToPositionX:(float)x Animated:(bool)animated;
- (void) hideAnimated:(bool)animated Notify:(bool)notify;

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

@interface MidasMasterMenuManager : MidasPopupManager
{
	MidasMasterMenuViewController * viewController;
}

+(MidasMasterMenuManager *)Instance;

@end

@interface MidasStandingsManager : MidasPopupManager
{
	MidasStandingsViewController * viewController;
}

+(MidasStandingsManager *)Instance;

@end

@interface MidasCircuitViewManager : MidasPopupManager
{
	MidasCircuitViewController * viewController;
}

+(MidasCircuitViewManager *)Instance;

@end

@interface MidasFollowDriverManager : MidasPopupManager
{
	MidasFollowDriverViewController * viewController;
}

+(MidasFollowDriverManager *)Instance;

@end

@interface MidasCameraManager : MidasPopupManager
{
	MidasCameraViewController * viewController;
}

+(MidasCameraManager *)Instance;

@end

@interface MidasHeadToHeadManager : MidasPopupManager
{
	MidasHeadToHeadViewController * viewController;
}

+(MidasHeadToHeadManager *)Instance;

@end

@interface MidasMyTeamManager : MidasPopupManager
{
	MidasMyTeamViewController * viewController;
}

+(MidasMyTeamManager *)Instance;

@end

@interface MidasVIPManager : MidasPopupManager
{
	MidasVIPViewController * viewController;
}

+(MidasVIPManager *)Instance;

@end

@interface MidasHelpManager : MidasPopupManager
{
	MidasHelpViewController * viewController;
}

+(MidasHelpManager *)Instance;

@end

@interface MidasAlertsManager : MidasPopupManager
{
	MidasAlertsViewController * viewController;
}

+(MidasAlertsManager *)Instance;

@end

@interface MidasSocialMediaManager : MidasPopupManager
{
	MidasSocialViewController * viewController;
}

+(MidasSocialMediaManager *)Instance;

@end
