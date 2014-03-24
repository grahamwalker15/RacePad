//
//  CarViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "ShinyButton.h"

@class TelemetryView;
@class TrackProfileView;
@class CommentaryView;
@class TrackMapView;
@class BackgroundView;

@class AnimationTimer;

@protocol TelemetryCarViewControllerDelegate;

@interface CarViewController : BasePadViewController
{
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet TrackMapView * trackMapView;
	IBOutlet CommentaryView * commentaryView;
	IBOutlet TrackProfileView * trackProfileView;
	
	IBOutlet BackgroundView *trackMapContainer;
	IBOutlet UIButton *trackMapSizeButton;
	
	bool trackMapExpanded;
	bool trackMapPinched;
	float backupUserScale;
	
	bool commentaryAnimating;
	bool commentaryExpanded;
	
	AnimationTimer * animationTimer;
	CGRect animationRectStart;
	CGRect animationRectEnd;
	bool grabTitle;
}

- (void)positionOverlays;
- (void) prePositionOverlays;
- (void) postPositionOverlays;

- (void)showOverlays;
- (void)hideOverlays;
- (void)addBackgroundFrames;

- (IBAction) trackMapSizeChanged;
- (void) trackMapSizeAnimationDidFire:(id)alphaPtr;
- (void) trackMapSizeAnimationDidStop;

- (void) expandCommentaryView;
- (void) restoreCommentaryView;

- (void) viewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) commentaryExpansionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) commentaryRestorationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

@end

@interface TelemetryCarViewController : CarViewController
{
	IBOutlet TelemetryView * telemetryView;
	IBOutlet UIButton *mscButton;
	IBOutlet UIButton *rosButton;
	
	IBOutlet UIBarButtonItem * back_button_;
	IBOutlet UIBarButtonItem * title_;
}

@property (nonatomic, assign) id<TelemetryCarViewControllerDelegate> delegate;

- (bool) supportsCar: (NSString *)name;
- (void) chooseCar: (NSString *)name;

- (IBAction) chooseMSC:(id)sender;
- (IBAction) chooseROS:(id)sender;
- (IBAction) BackButton:(id)sender;


@end

@protocol TelemetryCarViewControllerDelegate <NSObject>

- (void) telemetryCarViewControllerBackButtonPressed:(TelemetryCarViewController*)viewController;
@end


