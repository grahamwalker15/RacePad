//
//  InfoViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "InfoChildController.h"
#import "HTMLViewController.h"
#import "InfoDriversController.h"
#import "InfoTeamsController.h"
#import "InfoStandingsController.h"
#import "InfoRulesController.h"
#import "InfoPartnersController.h"
#import "BackgroundView.h"

@interface InfoViewController : BasePadViewController
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
	
	IBOutlet ShinyButton * driversButton;
	IBOutlet ShinyButton * teamsButton;
	IBOutlet ShinyButton * circuitsButton;
	IBOutlet ShinyButton * rulesButton;
	IBOutlet ShinyButton * standingsButton;
	IBOutlet ShinyButton * partnersButton;
	
}

- (IBAction) buttonPressed:(id)sender;

- (void)showChildController:(InfoChildController *)controller;
- (void)hideChildController:(bool)animated;

@end
