//
//  SurveyViewController.h
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "TabletState.h"

@class SurveyView;
@class BackgroundView;

@interface SurveyViewController : BasePadViewController <CLLocationManagerDelegate>
{
	
	IBOutlet SurveyView *surveyView;
	IBOutlet BackgroundView *backgroundView;
	
	int corner;
	
	bool surveying;
}

@property (readonly) bool surveying;

+ (SurveyViewController *)Instance;

- (void) showOverlays;
- (void) hideOverlays;
- (void) positionOverlays;

- (void) toggleSurveying;

@end
