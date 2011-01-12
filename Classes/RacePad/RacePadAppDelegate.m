//
//  RacePadAppDelegate.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadAppDelegate.h"
#import "RacePadClientSocket.h"
#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadPrefs.h"

@implementation RacePadAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after app launch.
	
	// Create the co-ordinator
	[[RacePadCoordinator Instance] onStartUp];
	
	// Create the time controller and title bar controller
	[[RacePadTimeController Instance] onStartUp];
	[[RacePadTitleBarController Instance] onStartUp];
	
	// Load the prefs
	[RacePadPrefs Instance];
	
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	[[RacePadCoordinator Instance] willResignActive];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	
	[[RacePadCoordinator Instance] didBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[RacePadPrefs Instance] save];
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods


 // Optional UITabBarControllerDelegate method
/*
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	int x = 0;
}
*/


/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
 */

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc
{
    [tabBarController release];
    [window release];
	
    [super dealloc];
}

@end

