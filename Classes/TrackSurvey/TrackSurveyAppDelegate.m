//
//  TrackSurveyAppDelegate.m
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackSurveyAppDelegate.h"
#import "TrackSurveyTitleBarController.h"

@implementation TrackSurveyAppDelegate

@synthesize window;
@synthesize tabBarController;

-(id)init
{
	if(self =[super init])
	{
		[TrackSurveyTitleBarController Instance];
	}
	
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after app launch.
	
	// Load the prefs
	// [TrackSurveyPrefs Instance];


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
	
	// [[TrackSurveyPrefs Instance] save];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// [[TrackSurveyPrefs Instance] save];
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

