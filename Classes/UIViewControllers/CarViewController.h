//
//  CarViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"
#import "ShinyButton.h"

@class TelemetryView;
@class PitWindowView;
@class CommentaryView;
@class TrackMapView;
@class BackgroundView;

@class AnimationTimer;

@interface CarViewController : RacePadViewController
{
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet TrackMapView * trackMapView;
	IBOutlet CommentaryView * commentaryView;
	IBOutlet PitWindowView * pitWindowView;
	IBOutlet ShinyButton *pitWindowSimplifyButton;
	
	IBOutlet BackgroundView *trackMapContainer;
	IBOutlet UIButton *trackMapSizeButton;
	
	int car;
	
	bool trackMapExpanded;
	bool trackMapPinched;
	float backupUserScale;
	
	bool commentaryAnimating;
	bool commentaryExpanded;
	
	AnimationTimer * animationTimer;
	CGRect animationRectStart;
	CGRect animationRectEnd;	
}

@property (nonatomic) int car;

- (void)positionOverlays;
- (void) prePositionOverlays;
- (void) postPositionOverlays;

- (void)showOverlays;
- (void)hideOverlays;
- (void)addBackgroundFrames;

- (IBAction) trackMapSizeChanged;
- (void) trackMapSizeAnimationDidFire:(id)alphaPtr;
- (void) trackMapSizeAnimationDidStop;

- (IBAction) pitWindowSimplifyPressed:(id)sender;

- (void) expandCommentaryView;
- (void) restoreCommentaryView;

- (void) viewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) commentaryExpansionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;
- (void) commentaryRestorationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

@end

@interface TelemetryCarViewController : CarViewController
{
	IBOutlet TelemetryView * telemetryView;
}

@end

@interface BlueCarViewController : TelemetryCarViewController
{
}

@end

@interface RedCarViewController : TelemetryCarViewController
{
}

@end


