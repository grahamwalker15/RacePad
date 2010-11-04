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
	IBOutlet id ip_address_edit_;
}

-(IBAction)IPAddressChanged:(id)sender;

@end
