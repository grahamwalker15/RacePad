//
//  SettingsViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"


@interface SettingsViewController : BasePadViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	IBOutlet UITextField *ip_address_edit_;
	IBOutlet UITextField *video_ip_address_edit_;
	IBOutlet UIButton *connect;
	IBOutlet UIButton *video_connect;
	IBOutlet UIButton *loadArchive;
	IBOutlet UIButton *restart;
	IBOutlet UIButton *exit;
	IBOutlet UIPickerView *event;
	IBOutlet UILabel *status;
	IBOutlet UILabel *video_status;
	IBOutlet UILabel *video_label;
	IBOutlet UISwitch *supportVideo;
	IBOutlet UISwitch *diagnosticsSwitch;
	IBOutlet UILabel *locationLabel;
	IBOutlet UISegmentedControl *bubbleType;
	IBOutlet UISegmentedControl *locationSwitch;

	IBOutlet UIActivityIndicatorView *serverTwirl;
	IBOutlet UIActivityIndicatorView *videoServerTwirl;
	
	NSMutableArray *events;
	NSMutableArray *sessions;
}

- (IBAction)IPAddressChanged:(id)sender;
- (IBAction)connectPressed:(id)sender;
- (IBAction)videoIPAddressChanged:(id)sender;
- (IBAction)videoConnectPressed:(id)sender;
- (IBAction)loadPressed:(id)sender;
- (IBAction)restartPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;
- (IBAction)supportVideoChanged:(id)sender;
- (IBAction)bubbleTypeChanged:(id)sender;
- (IBAction)diagnosticsChanged:(id)sender;
- (IBAction)locationChanged:(id)sender;

- (void) updateEvents;
- (void) updateServerAddresses;
- (void) updateServerState;
- (void) updateConnectionType;
- (void) updateSponsor;

- (BOOL) wantTimeControls;

@end
