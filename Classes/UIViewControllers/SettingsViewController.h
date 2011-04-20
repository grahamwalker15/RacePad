//
//  SettingsViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RacePadViewController.h"


@interface SettingsViewController : RacePadViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	IBOutlet UITextField *ip_address_edit_;
	IBOutlet UIButton *connect;
	IBOutlet UIButton *loadArchive;
	IBOutlet UIButton *restart;
	IBOutlet UIButton *exit;
	IBOutlet UIPickerView *event;
	IBOutlet UILabel *status;
	IBOutlet UISwitch *supportVideo;
	
	NSMutableArray *events;
	NSMutableArray *sessions;
}

-(IBAction)IPAddressChanged:(id)sender;
-(IBAction)connectPressed:(id)sender;
- (IBAction)loadPressed:(id)sender;
- (IBAction)restartPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;
- (IBAction)supportVideoChanged:(id)sender;

- (void) updateEvents;
- (void) updateServerState;
- (void) updateConnectionType;
- (void) updateSponsor;

- (BOOL) wantTimeControls;

@end
