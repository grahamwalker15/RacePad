//
//  DrivingViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"

@class TelemetryView;
@class TrackMapView;
@class BackgroundView;

@interface DrivingViewController : RacePadViewController
{
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet TelemetryView * telemetryView;
	IBOutlet TrackMapView * trackMapView;
	
	IBOutlet BackgroundView *trackMapContainer;

	IBOutlet UIButton *stop;
	IBOutlet UIButton *brake;
	IBOutlet UIButton *throttle;

	int car;
	BOOL disableRotation;

	UIInterfaceOrientation viewOrientation;
}

@property (nonatomic) int car;

- (void)positionOverlays;
- (void)showOverlays;
- (void)hideOverlays;
-(IBAction) stopPressed:(id)sender;
-(IBAction) controlPressed:(id)sender;
-(IBAction) controlReleased:(id)sender;

@end


