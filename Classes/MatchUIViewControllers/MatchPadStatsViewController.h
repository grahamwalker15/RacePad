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
}

- (void) hideStatsControllers;

-(IBAction)buttonSelected:(id)sender;

@end
