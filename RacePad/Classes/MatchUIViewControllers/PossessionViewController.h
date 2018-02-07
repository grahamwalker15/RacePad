//
//  PossessionViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "ShinyButton.h"

@class PossessionView;
@class BackgroundView;

@class AnimationTimer;

@interface PossessionViewController : BasePadPopupViewController
{
	IBOutlet BackgroundView *backgroundView;
	IBOutlet PossessionView * possessionView;
	
	bool animating;
	bool showPending;
	bool hidePending;
}

- (void) positionOverlays;
- (void) prePositionOverlays;
- (void) postPositionOverlays;

- (void) showOverlays;
- (void) hideOverlays;

@end
