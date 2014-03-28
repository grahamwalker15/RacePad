//
//  BasePadAppDelegate.m
//  BasePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BasePadAppDelegate.h"
#import "BasePadClientSocket.h"
#import "BasePadCoordinator.h"
#import "BasePadMedia.h"
#import "BasePadTimeController.h"
#import "BasePadTitleBarController.h"
#import "BasePadPrefs.h"
#import "BasePadSponsor.h"

@implementation BasePadAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after app launch.
	
	// Start the coordinator, media handler etc.
	[self startBaseServices];
	
    // Add the tab bar controller's current view as a subview of the window
	// Add the home controller's current view as a subview of the window
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_4_2)
	{
		[window addSubview:tabBarController.view];
	}
	else
	{
		[window setRootViewController:tabBarController];
	}
    [window makeKeyAndVisible];

    float r,g,b;
    [[BasePadSponsor Instance]primaryBrandingColor:&r:&g:&b];

    tabBarController.view.tintColor = [UIColor colorWithRed:r green:g blue:b alpha:1];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// There's some start-up race condition that means this doesn't display unless we delay slightly
	[[BasePadCoordinator Instance] performSelector:@selector(onDisplayFirstView) withObject:nil afterDelay: 0.1];
	// [[BasePadCoordinator Instance] onDisplayFirstView];
    return YES;
}

- (void) startBaseServices
{
    
    // Override point for customization after app launch.
	
	// Create the co-ordinator
	[[BasePadCoordinator Instance] onStartUp];
	
	// Create the media handler
	[[BasePadMedia Instance] onStartUp];
	
	// Create the time controller and title bar controller
	[[BasePadTimeController Instance] onStartUp];
	[[BasePadTitleBarController Instance] onStartUp];
	
	// Load the prefs
	[BasePadPrefs Instance];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
	[[BasePadCoordinator Instance] willResignActive];
	[[BasePadPrefs Instance] save];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	
	[[BasePadCoordinator Instance] didBecomeActive];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[[BasePadPrefs Instance] save];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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

