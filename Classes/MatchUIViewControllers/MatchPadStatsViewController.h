//
//  MatchPadStatsViewController.h
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "BasePadPopupViewController.h"

@interface MatchPadStatsViewController : BasePadPopupViewController
{
	IBOutlet UIButton * teamStatsButton;
	IBOutlet UIButton * playerStatsButton;
	IBOutlet UIButton * physicalStatsButton;
	IBOutlet UIButton * ballStatsButton;
	IBOutlet UIButton * possessionStatsButton;
	IBOutlet UIButton * pitchStatsButton;
	
	IBOutlet UIButton * teamStatsLabel;
	IBOutlet UIButton * playerStatsLabel;
	IBOutlet UIButton * physicalStatsLabel;
	IBOutlet UIButton * ballStatsLabel;
	IBOutlet UIButton * possessionStatsLabel;
	IBOutlet UIButton * pitchStatsLabel;
}

- (void) hideStatsControllers;

-(IBAction)buttonSelected:(id)sender;

@end
