//
//  SettingsViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"


@interface SettingsViewController : RacePadViewController
{
	IBOutlet UITextField *ip_address_edit_;
	IBOutlet UIButton *serverStatus;
	IBOutlet UISegmentedControl *modeControl;
	IBOutlet UIButton *event;
	
	UIImage *connectedImage;
	UIImage *disconnectedImage;
	
	bool changingMode;
}

-(IBAction)IPAddressChanged:(id)sender;
-(IBAction)serverStatusPressed:(id)sender;
-(IBAction)modeChanged:(id)sender;
-(IBAction)eventPressed:(id)sender;

- (void) updateServerState;
- (void) updateConnectionType;

@end
