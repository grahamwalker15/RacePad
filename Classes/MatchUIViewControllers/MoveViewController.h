//
//  MoveViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "ShinyButton.h"

@class MoveView;
@class BackgroundView;

@class AnimationTimer;

enum H2HDragSource {
	H2H_VC_LEADERBOARD_,
	H2H_VC_DRIVER1_,
	H2H_VC_DRIVER2_
};

@interface MoveViewController : BasePadViewController
{
	IBOutlet BackgroundView *backgroundView;

	IBOutlet MoveView * moveView;
	
	bool animating;
	bool showPending;
	bool hidePending;
	
}

- (void)positionOverlays;
- (void) prePositionOverlays;
- (void) postPositionOverlays;

- (void)showOverlays;
- (void)hideOverlays;
- (void)addBackgroundFrames;

- (void)RequestRedraw;

@end
