//
//  AlertViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "AlertView.h"

@interface AlertViewController : SimpleListViewController
{
	IBOutlet AlertView * alertView;
	IBOutlet UIBarButtonItem * closeButton;
	IBOutlet UISegmentedControl * typeChooser;
	
	UIPopoverController * parentPopover;
}

@property (nonatomic, retain) UIPopoverController * parentPopover;

- (void) UpdateList;

- (void) dismissTimerExpired:(NSTimer *)theTimer;

- (IBAction) closePressed:(id)sender;
- (IBAction) typeChosen:(id)sender;

@end
