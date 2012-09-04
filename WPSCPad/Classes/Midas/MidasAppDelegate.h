//
//  MidasAppDelegate.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadAppDelegate.h"

@class MidasHomeViewController;
	
@interface MidasAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UIViewController *mainViewController;
    UITabBarController *tabBarController;	// Needs to be present so that RacePadCoordinator can work. Set to nil.
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *mainViewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
