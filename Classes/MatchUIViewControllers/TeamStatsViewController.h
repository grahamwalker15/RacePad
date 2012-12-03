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

@interface TeamStatsViewController : BasePadPopupViewController
{
	IBOutlet AlertView * alertView;
	IBOutlet UISegmentedControl * typeChooser;
}
		
@end
