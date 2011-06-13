//
//  BasePadTitleBar.h
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarViewController.h"
#import "HelpViewController.h"

@interface BasePadTitleBarController : NSObject <UIPopoverControllerDelegate>
{
	TitleBarViewController * titleBarController;
		
	HelpViewController * helpController;
	UIPopoverController * helpPopover;
	
	bool liveMode;
}

+ (BasePadTitleBarController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController;
- (void) hide;

- (void) updateTime:(float)time;
- (void) setEventName: (NSString *)event;

- (void) updateLiveIndicator;
- (void) hideLiveIndicator;
- (void) showLiveIndicator;

- (void) updateSponsor;

- (IBAction)HelpPressed:(id)sender;

@end
