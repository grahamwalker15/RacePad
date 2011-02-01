//
//  RacePadTitleBar.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarViewController.h"
#import "AlertViewController.h"
#import "HelpViewController.h"

@interface RacePadTitleBarController : NSObject <UIPopoverControllerDelegate>
{
	TitleBarViewController * titleBarController;
	AlertViewController * alertController;
	UIPopoverController * alertPopover;
	
	HelpViewController * helpController;
	UIPopoverController * helpPopover;
	
	int lapCount;
	int currentLap;
}

+ (RacePadTitleBarController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController;
- (void) hide;

- (void) updateTime:(float)time;
- (void) setEventName: (NSString *)event;
- (void) setLapCount: (int)count;
- (void) setCurrentLap: (int)lap;
- (int) inqCurrentLap;
- (void) setTrackState: (int)state;

- (IBAction)AlertPressed:(id)sender;
- (IBAction)HelpPressed:(id)sender;

@end
