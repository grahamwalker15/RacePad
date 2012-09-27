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
#import "MidasCoordinator.h"

#import "BasePadVideoViewController.h"
#import "TrackMapView.h"
#import "DrawingView.h"
#import "MovieView.h"
#import "LeaderboardView.h"
#import "BackgroundView.h"

@interface MidasVideoViewController : BasePadVideoViewController <MidasPopupParentDelegate, MidasSocialmediaResponderDelegate, MovieViewDelegate>
{
	IBOutlet UIImageView * copyright;

	IBOutlet MovieView * mainMovieView;
	IBOutlet MovieView * auxMovieView1;	
	IBOutlet MovieView * auxMovieView2;
		
	IBOutlet UIView * mainMovieViewTitleView;
	IBOutlet UIImageView * mainMovieViewTitleBackgroundImage;
	IBOutlet UIButton * mainMovieViewDriverName;
	IBOutlet UIButton * mainMovieViewMovieType;
	
	IBOutlet UIView * auxMovieView1TitleView;
	IBOutlet UIImageView * auxMovieView1TitleBackgroundImage;
	IBOutlet UIImageView * auxMovieView1AudioImage;
	IBOutlet UIButton * auxMovieView1DriverName;
	IBOutlet UIButton * auxMovieView1MovieType;
	IBOutlet UIButton * auxMovieView1CloseButton;
	
	IBOutlet UIView * auxMovieView2TitleView;
	IBOutlet UIImageView * auxMovieView2TitleBackgroundImage;
	IBOutlet UIImageView * auxMovieView2AudioImage;
	IBOutlet UIButton * auxMovieView2DriverName;
	IBOutlet UIButton * auxMovieView2MovieType;
	IBOutlet UIButton * auxMovieView2CloseButton;
	
	IBOutlet UIImageView * mainMovieViewLoadingScreen;

	IBOutlet UILabel * auxMovieView1LoadingLabel;
	IBOutlet UIActivityIndicatorView * auxMovieView1LoadingTwirl;	
	IBOutlet UILabel * auxMovieView1ErrorLabel;
	IBOutlet UIImageView * auxMovieView1LoadingScreen;
	
	IBOutlet UILabel * auxMovieView2LoadingLabel;
	IBOutlet UIActivityIndicatorView * auxMovieView2LoadingTwirl;	
	IBOutlet UILabel * auxMovieView2ErrorLabel;
	IBOutlet UIImageView * auxMovieView2LoadingScreen;
	
	IBOutlet UIView * overlayView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet BackgroundView * trackZoomContainer;
	IBOutlet TrackMapView * trackZoomView;
	IBOutlet UIButton * trackZoomCloseButton;
	IBOutlet LeaderboardView *leaderboardView;
	
	IBOutlet UIView * bottomButtonPanel;
	IBOutlet UIView * topButtonPanel;

	IBOutlet UIButton * midasMenuButton;
	
	IBOutlet UIButton * helpButton;
	IBOutlet UIButton * alertsButton;
	IBOutlet UIButton * socialMediaButton;
	IBOutlet UIButton * vipButton;
	IBOutlet UIButton * dfButton;
	
	IBOutlet UIButton * lapCounterButton;
	IBOutlet UIImageView * trackStateButton;
	
	IBOutlet UIButton * standingsButton;
	IBOutlet UIButton * mapButton;
	IBOutlet UIButton * followDriverButton;
	IBOutlet UIButton * cameraButton;
	IBOutlet UIButton * timeControlsButton;
	IBOutlet UIButton * myTeamButton;
	
	IBOutlet UIImageView * moreLeftImage;
	IBOutlet UIImageView * moreRightImage;
	
	IBOutlet UIImageView * pushNotificationAnimationImage;
	IBOutlet UILabel * pushNotificationAnimationLabel;
	
	bool midasMenuButtonOpen;
	bool helpButtonOpen;
	bool alertsButtonOpen;
	bool socialMediaButtonOpen;	
	bool vipButtonOpen;

	bool lapCounterButtonOpen;
	bool standingsButtonOpen;
	bool mapButtonOpen;
	bool followDriverButtonOpen;
	bool cameraButtonOpen;
	bool timeControlsButtonOpen;
	bool myTeamButtonOpen;
	
	bool socialMediaButtonFlashed;
	bool timeControllerPending;

	CGSize movieSize;
	CGRect movieRect;
	
	int priorityAuxMovie;
	bool movieViewsStored;
	
	int unselectedButtonWidth;
	int selectedButtonWidth;
	
	bool displayVideo;
	bool displayMap;
	bool displayLeaderboard;
	
	bool disableOverlays;
	bool allowBubbleCommentary;
	
	bool menuButtonsDisplayed;
	bool menuButtonsAnimating;
	bool moviesAnimating;
	bool firstDisplay;
	
	UIButton * flashedMenuButton;
		
	int trackZoomOffsetX, trackZoomOffsetY;
}

@property (nonatomic) bool displayVideo;
@property (nonatomic) bool displayMap;
@property (nonatomic) bool displayLeaderboard;

@property (nonatomic) bool allowBubbleCommentary;

@property (nonatomic) bool midasMenuButtonOpen;
@property (nonatomic) bool helpButtonOpen;
@property (nonatomic) bool alertsButtonOpen;
@property (nonatomic) bool socialMediaButtonOpen;	
@property (nonatomic) bool vipButtonOpen;
@property (nonatomic) bool lapCounterButtonOpen;
@property (nonatomic) bool standingsButtonOpen;
@property (nonatomic) bool mapButtonOpen;
@property (nonatomic) bool followDriverButtonOpen;
@property (nonatomic) bool cameraButtonOpen;
@property (nonatomic) bool timeControlsButtonOpen;
@property (nonatomic) bool myTeamButtonOpen;

@property (readonly) MovieView * mainMovieView;
@property (readonly) MovieView * auxMovieView1;
@property (readonly) MovieView * auxMovieView2;


- (void) setTrackState: (int)state;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void)setMapDisplayed:(bool)state;
- (void)setOverlaysDisabled:(bool)state;

- (bool) displayMovieSource:(BasePadVideoSource *)source InView:(MovieView *)view;
- (void) prePositionMovieView:(MovieView *)newView From:(int)movieDirection;
- (void) positionMovieViews;

- (int) countMovieViews;

- (void) storeMovieViews;
- (void) restoreMovieViews;
- (void) clearMovieViewStore;

- (void) showZoomMap;
- (void) hideZoomMap;
- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) positionMenuButtons;
- (void) positionTopMenuButtons;
- (void) positionBottomMenuButtons;
- (void) hideMenuButtons;
- (void) showMenuButtons;
- (void) menuAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) prepareToAnimateMovieViews:(MovieView *)newView From:(int)movieDirection;
- (void) animateMovieViews:(MovieView *)newView From:(int)movieDirection;
- (void) movieViewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) showAuxMovieViewByIndex:(int)viewNumber;
- (void) hideAuxMovieViewByIndex:(int)viewNumber;
- (void) showAuxMovieView:(MovieView *)viewPtr;
- (void) hideAuxMovieView:(MovieView *)viewPtr;
- (MovieView *) auxMovieView:(int)viewNumber;
- (MovieView *) findFreeMovieView;

- (void) flashMenuButton:(UIButton *)button WithName:(NSString *)name;
- (void) flashMenuButton:(UIButton *)button;
- (void) setFlashStateForButton:(UIButton *)button ToState:(bool)flashState Animated:(bool)animated;
- (void) menuFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) menuEndFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

-(void) animateMenuButton:(UIButton *)button;
- (void) menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) executeTimeControllerDisplay;
- (void) executeTimeControllerHide;

- (void) handleMenuButtonDisplayGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

- (IBAction) movieCloseButtonHit:(id)sender;
- (IBAction) closeButtonHit:(id)sender;

- (IBAction) menuButtonHit:(id)sender;
- (bool) dismissPopupViews;
- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus;

@end
