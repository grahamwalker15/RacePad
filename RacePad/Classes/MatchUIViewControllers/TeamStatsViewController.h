//
//  TeamStatsViewController.h
//  MatchPad
//
//  Created by Gareth Griffith on 12/3/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadPopupViewController.h"
#import "AlertView.h"

@class TeamStatsView;

@interface TeamStatsViewController : BasePadPopupViewController
{
	IBOutlet UISegmentedControl * typeChooser;
	IBOutlet TeamStatsView *team_stats_view_;
}
		
@end
