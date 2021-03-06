//
//  TrackMapViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@class TrackMapView;
@class BackgroundView;
@class TableDataView;
@class LeaderboardView;

@interface TrackMapViewController : BasePadViewController
{
	
	IBOutlet TrackMapView *trackMapView;
	IBOutlet BackgroundView *backgroundView;
	IBOutlet BackgroundView * trackZoomContainer;
	IBOutlet TrackMapView * trackZoomView;
	IBOutlet LeaderboardView *leaderboardView;
	
	IBOutlet UIButton * trackZoomCloseButton;

	int trackZoomOffsetX, trackZoomOffsetY;
}

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) showZoomMap;
- (void) hideZoomMap;
- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) closeButtonHit:(id)sender;


@end
