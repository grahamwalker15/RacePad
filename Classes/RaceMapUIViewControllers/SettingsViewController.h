//
//  SettingsViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"


@interface SettingsViewController : BasePadViewController
{
	IBOutlet UITextField *ip_address_edit_;
	IBOutlet UITextField *mc_ip_address_edit_;
	IBOutlet UIButton *connect;
	IBOutlet UIButton *restart;
	IBOutlet UIButton *exit;
	IBOutlet UILabel *status;

	IBOutlet UIActivityIndicatorView *serverTwirl;
}

- (IBAction)IPAddressChanged:(id)sender;
- (IBAction)connectPressed:(id)sender;
- (IBAction)mcIPAddressChanged:(id)sender;
- (IBAction)restartPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;

- (void) updateServerState;
- (void) updateConnectionType;
- (void) updateSponsor;

@end
