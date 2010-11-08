//
//  RacePadTitleBar.h
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarViewController.h"

@interface RacePadTitleBarController : NSObject
{
	TitleBarViewController * titleBarController;
}

+ (RacePadTitleBarController *)Instance;

- (void) onStartUp;

- (void) displayInViewController:(UIViewController *)viewController;
- (void) hide;

- (void) updateClock:(float)time;
- (void) setEventName: (NSString *)event;

@end
