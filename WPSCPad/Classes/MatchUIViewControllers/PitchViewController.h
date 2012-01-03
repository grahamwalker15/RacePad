//
//  TrackMapViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@class PitchView;
@class BackgroundView;
@class TableDataView;

@interface PitchViewController : BasePadViewController
{
	
	IBOutlet PitchView *pitchView;
	IBOutlet BackgroundView *backgroundView;
	IBOutlet BackgroundView * pitchZoomContainer;
	IBOutlet PitchView * pitchZoomView;
	
	int pitchZoomOffsetX, pitchZoomOffsetY;
}

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) showZoomMap;
- (void) hideZoomMap;
- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

@end
