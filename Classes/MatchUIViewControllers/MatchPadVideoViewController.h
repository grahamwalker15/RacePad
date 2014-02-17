//
//  MatchPadVideoViewController.h
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

#import "MatchPadPopupManager.h"
#import "MatchPadCoordinator.h"

#import "BasePadVideoViewController.h"
#import "DrawingView.h"
#import "MovieView.h"
#import "PitchView.h"
#import "BackgroundView.h"

@interface MatchPadVideoViewController : BasePadVideoViewController <BasePadPopupParentDelegate, MovieViewDelegate>
{
	IBOutlet UIImageView * copyright;

	IBOutlet UIButton * scoreButton;
	IBOutlet UILabel * homeTeamLabel;
	IBOutlet UILabel * awayTeamLabel;
	IBOutlet UILabel * homeScoreLabel;
	IBOutlet UILabel * awayScoreLabel;

	IBOutlet MovieView * mainMovieView;
	IBOutlet MovieView * auxMovieView1;	
	IBOutlet MovieView * auxMovieView2;
		
	IBOutlet UIView * mainMovieViewTitleView;
	IBOutlet UIImageView * mainMovieViewTitleBackgroundImage;
	IBOutlet UIButton * mainMovieViewMovieType;
	IBOutlet UIButton * mainMovieViewCloseButton;
		
	IBOutlet UIImageView * mainMovieViewLoadingScreen;
		
	IBOutlet UIView * auxMovieView1TitleView;
	IBOutlet UIImageView * auxMovieView1TitleBackgroundImage;
	IBOutlet UIButton * auxMovieView1MovieType;
	IBOutlet UIButton * auxMovieView1CloseButton;
	
	IBOutlet UIView * auxMovieView2TitleView;
	IBOutlet UIImageView * auxMovieView2TitleBackgroundImage;
	IBOutlet UIButton * auxMovieView2MovieType;
	IBOutlet UIButton * auxMovieView2CloseButton;
	
	IBOutlet UILabel * auxMovieView1LoadingLabel;
	IBOutlet UIActivityIndicatorView * auxMovieView1LoadingTwirl;	
	IBOutlet UILabel * auxMovieView1ErrorLabel;
	IBOutlet UIImageView * auxMovieView1LoadingScreen;
	
	IBOutlet UILabel * auxMovieView2LoadingLabel;
	IBOutlet UIActivityIndicatorView * auxMovieView2LoadingTwirl;	
	IBOutlet UILabel * auxMovieView2ErrorLabel;
	IBOutlet UIImageView * auxMovieView2LoadingScreen;
	
	IBOutlet UIView * overlayView;
	IBOutlet PitchView * pitchView;
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet UIButton * mainMenuButton;
	
	IBOutlet UIButton * statsButton;
	IBOutlet UIButton * highlightsButton;
	IBOutlet UIButton * replaysButton;
	
	IBOutlet UIButton * settingsButton;
	IBOutlet UIButton * helpButton;
			
	IBOutlet UIView * logoImageBase;
	IBOutlet UIImageView * logoImageView0;
	IBOutlet UIImageView * logoImageView1;
	
	bool mainMenuButtonOpen;
	bool settingsButtonOpen;
	bool helpButtonOpen;
	bool statsButtonOpen;
	bool replaysButtonOpen;
	bool highlightsButtonOpen;

	bool timeControllerPending;

	CGSize movieSize;
	CGRect movieRect;
		
	bool displayVideo;
	bool displayPitch;
	bool displayLogos;
	
	bool allowBubbleCommentary;
	
	bool menuButtonsDisplayed;
	bool menuButtonsAnimating;
	bool moviesAnimating;

	bool firstDisplay;
	bool autoHideButtons;
	
	bool popupNotificationPending;
	
	int priorityAuxMovie;
    			    
    NSTimer *logoAnimationTimer;
    int currentLogoIndex;
    int currentLogoImageView;
}

@property (nonatomic) bool displayVideo;
@property (nonatomic) bool displayPitch;
@property (nonatomic) bool displayLogos;

@property (nonatomic) bool allowBubbleCommentary;

@property (nonatomic) bool mainMenuButtonOpen;
@property (nonatomic) bool settingsButtonOpen;
@property (nonatomic) bool helpButtonOpen;
@property (nonatomic) bool statsButtonOpen;
@property (nonatomic) bool highlightsButtonOpen;
@property (nonatomic) bool replaysButtonOpen;

@property (readonly) MovieView * mainMovieView;
@property (readonly) MovieView * auxMovieView1;
@property (readonly) MovieView * auxMovieView2;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void)setVideoDisplayed:(bool)state;
- (void)setPitchDisplayed:(bool)state;

- (bool) displayMovieSource:(BasePadVideoSource *)source InView:(MovieView *)view;
- (void) prePositionMovieView:(MovieView *)newView From:(int)movieDirection;
- (void) positionMovieViews;

- (int) countMovieViews;

- (void) showAuxMovieView:(MovieView *)viewPtr;
- (void) hideAuxMovieView:(MovieView *)viewPtr;
- (void) showAuxMovieViewByIndex:(int)viewNumber;
- (void) hideAuxMovieViewByIndex:(int)viewNumber;
- (MovieView *) auxMovieView:(int)viewNumber;
- (MovieView *) findFreeMovieView;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) positionMenuButtons;
- (void) hideMenuButtons;
- (void) showMenuButtons;
- (void) menuAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) prepareToAnimateMovieViews:(MovieView *)newView From:(int)movieDirection;
- (void) animateMovieViews:(MovieView *)newView From:(int)movieDirection;
- (void) movieViewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) animateMenuButton:(UIButton *)button;
- (void) menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) executeTimeControllerDisplay;
- (void) executeTimeControllerHide;

- (void) handleMenuButtonDisplayGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y;

- (void) updateScore;

- (IBAction) movieCloseButtonHit:(id)sender;
- (IBAction) menuButtonHit:(id)sender;
- (IBAction) closeButtonHit:(id)sender;

- (bool) dismissPopupViews;
- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus;

- (void) initialiseLogoImages;
- (void) showLogoImages;
- (void) hideLogoImages;
- (void) hideLogoImagesAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) startLogoAnimation;
- (void) endLogoAnimation;
- (bool) setNextLogoImage:(int)imageIndex InView:(int)viewIndex;
- (void) logoAnimationTimerFired: (NSTimer *)theTimer;

- (IBAction) logoDisplayButtonHit:(id)sender;

@end
