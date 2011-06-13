//
//  RacePadTitleBar.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadTitleBarController.h"
#import "TitleBarViewController.h"
#import "AlertViewController.h"
#import "HelpViewController.h"

@interface RacePadTitleBarController : BasePadTitleBarController
{
	AlertViewController * alertController;
	UIPopoverController * alertPopover;

	int lapCount;
	int currentLap;
}

+ (RacePadTitleBarController *)Instance;

- (void) setLapCount: (int)count;
- (void) setCurrentLap: (int)lap;
- (int) inqCurrentLap;
- (void) setTrackState: (int)state;

- (IBAction)AlertPressed:(id)sender;

@end
