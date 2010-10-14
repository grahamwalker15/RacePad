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

@interface TrackMapViewController : DrawingViewController
{
	
	TrackMapView *track_map_view_;
	
}

- (void)RequestRedraw;

@end
