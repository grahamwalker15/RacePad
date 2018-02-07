//
//  SettingsViewController.h
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
///

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "TabletState.h"

@interface SettingsViewController : BasePadViewController <CLLocationManagerDelegate>
{
	IBOutlet UIButton *restart;
	IBOutlet UIButton *exit;
	IBOutlet UIButton *recordSurvey;
	IBOutlet UITextField *surveyText;
	IBOutlet UILabel *surveyPosition;
}

- (IBAction)restartPressed:(id)sender;
- (IBAction)exitPressed:(id)sender;
- (IBAction)recordSurveyPressed:(id)sender;
- (IBAction)surveyTextChanged:(id)sender;

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
