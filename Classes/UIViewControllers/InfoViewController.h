//
//  InfoViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"
#import "HTMLViewController.h"
#import "BackgroundView.h"

@interface InfoViewController : RacePadViewController
{
	HTMLViewController * htmlController;
	
	bool childControllerDisplayed;
	bool childControllerClosing;
	
	IBOutlet UIButton * driversButton;
	IBOutlet UIButton * teamsButton;
	IBOutlet UIButton * circuitsButton;
	IBOutlet UIButton * rulesButton;
	IBOutlet UIButton * standingsButton;
	IBOutlet UIButton * partnersButton;
	
}

- (IBAction) buttonPressed:(id)sender;

- (void)showHTMLController:(NSString *)htmlName;
- (void)hideChildController:(bool)animated;

@end
