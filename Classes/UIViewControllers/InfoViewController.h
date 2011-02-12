//
//  InfoViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"
#import "InfoChildController.h"
#import "HTMLViewController.h"
#import "InfoDriversController.h"
#import "InfoTeamsController.h"
#import "InfoStandingsController.h"
#import "InfoRulesController.h"
#import "InfoPartnersController.h"
#import "BackgroundView.h"

@interface InfoViewController : RacePadViewController
{
	HTMLViewController * htmlController;
	InfoDriversController * driversController;
	InfoTeamsController * teamsController;
	InfoStandingsController * standingsController;
	InfoRulesController * rulesController;
	InfoPartnersController * partnersController;
	
	InfoChildController * childController;
	
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

- (void)showChildController:(InfoChildController *)controller;
- (void)hideChildController:(bool)animated;

@end
