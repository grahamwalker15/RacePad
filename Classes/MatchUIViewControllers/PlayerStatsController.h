//
//  PlayerStatsController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "TableDataView.h"
#import "ShinyButton.h"

@interface PlayerStatsController : SimpleListViewController
{
	IBOutlet TableDataView * player_stats_view_;
	IBOutlet ShinyButton *homeButton;
	IBOutlet ShinyButton *awayButton;
	
	bool home;
}

@property bool home;

- (IBAction)homePressed:(id)sender;
- (IBAction)awayPressed:(id)sender;


@end
