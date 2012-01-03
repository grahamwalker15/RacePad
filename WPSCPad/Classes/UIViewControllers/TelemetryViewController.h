//
//  TelemetryViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/22/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@class TelemetryView;
@class TrackMapView;
@class BackgroundView;

@interface TelemetryViewController : BasePadViewController
{
	IBOutlet BackgroundView *backgroundView;

	IBOutlet TelemetryView * blueTelemetryView;
	IBOutlet TelemetryView * redTelemetryView;
	
	IBOutlet TrackMapView * blueTrackMapView;
	IBOutlet TrackMapView * redTrackMapView;

	IBOutlet BackgroundView *blueTrackMapContainer;
	IBOutlet BackgroundView *redTrackMapContainer;
	
}

- (void)positionOverlays;
- (void)showOverlays;
- (void)hideOverlays;

@end
