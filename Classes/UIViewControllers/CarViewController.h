//
//  CarViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"

@class TelemetryView;
@class PitWindowView;
@class TrackMapView;
@class BackgroundView;

@class AnimationTimer;

@interface CarViewController : RacePadViewController
{
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet TelemetryView * telemetryView;
	IBOutlet TrackMapView * trackMapView;
	IBOutlet PitWindowView * pitWindowView;
	
	IBOutlet BackgroundView *trackMapContainer;
	IBOutlet UIButton *trackMapSizeButton;
	
	int car;
	
	bool trackMapExpanded;
	bool trackMapPinched;
	float backupUserScale;
	
	AnimationTimer * animationTimer;
	CGRect animationRectStart;
	CGRect animationRectEnd;	
}

@property (nonatomic) int car;

- (void)positionOverlays;
- (void)showOverlays;
- (void)hideOverlays;

- (IBAction) trackMapSizeChanged;
- (void) trackMapSizeAnimationDidFire:(id)alphaPtr;
- (void) trackMapSizeAnimationDidStop;

@end

@interface BlueCarViewController : CarViewController
{
}

@end

@interface RedCarViewController : CarViewController
{
}

@end


