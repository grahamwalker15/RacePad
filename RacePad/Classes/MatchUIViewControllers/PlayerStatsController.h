//
//  PlayerStatsController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "BackgroundView.h"
#import "TableDataView.h"
#import "ShinyButton.h"

@class PlayerGraphViewController;

@interface PlayerStatsController : BasePadPopupViewController <SimpleListViewDelegate>
{
	IBOutlet BackgroundView * backgroundView;
	
	IBOutlet TableDataView * player_stats_view_;
	IBOutlet ShinyButton *homeButton;
	IBOutlet ShinyButton *awayButton;
	
	PlayerGraphViewController *playerGraphViewController;
	
	bool playerGraphViewControllerDisplayed;
	bool playerGraphViewControllerClosing;
	
	bool home;
}

@property bool home;

- (IBAction)homePressed:(id)sender;
- (IBAction)awayPressed:(id)sender;

- (void)ShowPlayerGraph:(int)player;
- (void)HidePlayerGraph:(bool)animated;

@end
