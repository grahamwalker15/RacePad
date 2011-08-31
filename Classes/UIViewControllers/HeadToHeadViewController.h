//
//  HeadToHeadViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "ShinyButton.h"

@class HeadToHeadView;
@class LeaderboardView;
@class BackgroundView;

@interface HeadToHeadViewController : BasePadViewController
{
	IBOutlet BackgroundView *backgroundView;
	
	IBOutlet UIImageView * driver0Photo;
	IBOutlet UIImageView * driver0TextBG;
	IBOutlet UILabel * driver0FirstNameLabel;
	IBOutlet UILabel * driver0SurnameLabel;
	IBOutlet UILabel * driver0TeamLabel;

	IBOutlet UIImageView * driver1Photo;
	IBOutlet UIImageView * driver1TextBG;
	IBOutlet UILabel * driver1FirstNameLabel;
	IBOutlet UILabel * driver1SurnameLabel;
	IBOutlet UILabel * driver1TeamLabel;
	
	IBOutlet LeaderboardView * leaderboard0View;
	IBOutlet LeaderboardView * leaderboard1View;
	
	IBOutlet HeadToHeadView * headToHeadView;
}

- (void) prePositionOverlays;
- (void) postPositionOverlays;
- (void)positionOverlays;

- (void)showOverlays;
- (void)hideOverlays;
- (void)addBackgroundFrames;

@end


