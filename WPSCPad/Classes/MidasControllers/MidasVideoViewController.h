//
//  MidasVideoViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAsynchronousKeyValueLoading.h>

#import <CoreMedia/CMTime.h>

#import "MidasPopupManager.h"

#import "BasePadVideoViewController.h"
#import "TrackMapView.h"
#import "DrawingView.h"
#import "MovieView.h"
#import "LeaderboardView.h"
#import "BackgroundView.h"

@interface MidasVideoViewController : BasePadVideoViewController <MidasPopupParentDelegate>
{
	IBOutlet MovieView * movieView;
	IBOutlet UIView * overlayView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet BackgroundView * trackZoomContainer;
	IBOutlet TrackMapView * trackZoomView;
	IBOutlet UIButton * trackZoomCloseButton;
	IBOutlet LeaderboardView *leaderboardView;
	
	IBOutlet UIView * bottomButtonPanel;
	IBOutlet UIView * topButtonPanel;

	IBOutlet UIButton * midasMenuButton;
	
	IBOutlet UIButton * alertsButton;
	IBOutlet UIButton * twitterButton;
	IBOutlet UIButton * facebookButton;
	IBOutlet UIButton * midasChatButton;
	
	IBOutlet UIButton * lapCounterButton;
	IBOutlet UIButton * userNameButton;
	
	IBOutlet UIButton * standingsButton;
	IBOutlet UIButton * mapButton;
	IBOutlet UIButton * followDriverButton;
	IBOutlet UIButton * headToHeadButton;
	IBOutlet UIButton * timeControlsButton;
	IBOutlet UIButton * vipButton;
	IBOutlet UIButton * myTeamButton;
	
	IBOutlet UIImageView * moreLeftImage;
	IBOutlet UIImageView * moreRightImage;
	
	IBOutlet UIImageView * buttonBackgroundAnimationImage;
	
	bool midasMenuButtonOpen;
	bool alertsButtonOpen;
	bool twitterButtonOpen;
	bool facebookButtonOpen;
	bool midasChatButtonOpen;	
	bool lapCounterButtonOpen;
	bool userNameButtonOpen;
	bool standingsButtonOpen;
	bool mapButtonOpen;
	bool followDriverButtonOpen;
	bool headToHeadButtonOpen;
	bool timeControlsButtonOpen;
	bool vipButtonOpen;
	bool myTeamButtonOpen;
	
	CGSize movieSize;
	CGRect movieRect;
	
	int unselectedButtonWidth;
	int selectedButtonWidth;
	
	bool moviePlayerLayerAdded;
	
	bool displayVideo;
	bool displayMap;
	bool displayLeaderboard;
	
	bool menuButtonsDisplayed;
	bool menuButtonsAnimating;
	bool firstDisplay;
		
	int trackZoomOffsetX, trackZoomOffsetY;
}

@property (nonatomic) bool displayVideo;
@property (nonatomic) bool displayMap;
@property (nonatomic) bool displayLeaderboard;

@property (nonatomic) bool midasMenuButtonOpen;
@property (nonatomic) bool alertsButtonOpen;
@property (nonatomic) bool twitterButtonOpen;
@property (nonatomic) bool facebookButtonOpen;
@property (nonatomic) bool midasChatButtonOpen;	
@property (nonatomic) bool lapCounterButtonOpen;
@property (nonatomic) bool userNameButtonOpen;
@property (nonatomic) bool standingsButtonOpen;
@property (nonatomic) bool mapButtonOpen;
@property (nonatomic) bool followDriverButtonOpen;
@property (nonatomic) bool headToHeadButtonOpen;
@property (nonatomic) bool timeControlsButtonOpen;
@property (nonatomic) bool vipButtonOpen;
@property (nonatomic) bool myTeamButtonOpen;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) showZoomMap;
- (void) hideZoomMap;
- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) positionMenuButtons;
- (void) hideMenuButtons;
- (void) showMenuButtons;
- (void) menuAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) flashMenuButton:(UIButton *)button;
- (void) menuFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

-(void) animateMenuButton:(UIButton *)button;
- (void) menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) handleMenuButtonDisplayGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

- (IBAction) closeButtonHit:(id)sender;

- (IBAction) menuButtonHit:(id)sender;
- (bool) dismissPopupViews;
- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus;

@end
