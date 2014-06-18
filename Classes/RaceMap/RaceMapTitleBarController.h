//
//  RaceMapTitleBarController
//  RaceMap
//
//  Created by Simon Cuff on 17th June 2014
//  Copyright 2014 SBG Sports Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadTitleBarController.h"
#import "TitleBarViewController.h"
#import "AlertViewController.h"

@interface RaceMapTitleBarController : BasePadTitleBarController
{
	AlertViewController * alertController;
	UIPopoverController * alertPopover;
	
	int lapCount;
	int currentLap;
	int trackState;
}

@property (nonatomic) int lapCount;
@property (nonatomic) int currentLap;
@property (nonatomic) int trackState;

+ (RaceMapTitleBarController *)Instance;

- (void) setLapCount: (int)count;
- (int) inqCurrentLap;
- (void) setTrackState: (int)state;

- (IBAction)AlertPressed:(id)sender;
- (IBAction)PlayStatePressed:(id)sender;

- (void) displayInViewController:(UIViewController *)viewController SupportCommentary: (bool) supportCommentary;

@end
