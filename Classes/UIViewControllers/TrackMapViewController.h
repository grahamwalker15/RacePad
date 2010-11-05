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
@class TrackMapBackgroundView;
@class TableDataView;

@interface TrackMapViewController : DrawingViewController
{
	
	TrackMapView *trackMapView;
	IBOutlet TrackMapBackgroundView *background_view_;
	IBOutlet TableDataView *timing_view_;
	
}


@end
