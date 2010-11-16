//
//  TrackMapViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingViewController.h"
#import "ESRenderer.h"

@class TrackMapView;
@class BackgroundView;
@class TableDataView;
@class LeaderboardView;

@interface TrackMapViewController : DrawingViewController
{
	
	TrackMapView *trackMapView;
	IBOutlet BackgroundView *backgroundView;
	IBOutlet LeaderboardView *leaderboardView;
	
}


@end
